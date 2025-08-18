import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

function generateResetToken(email: string): string {
  const rand = crypto.randomBytes(32).toString("base64url");
  const base = `${email}:${Date.now()}:${rand}`;
  return crypto.createHash("sha256").update(base).digest("hex");
}

/**
 * Callable: verifyOtpAndIssueResetSession
 * Params: { email, code }
 * Reads otpCodes/{email}, validates (exists, not expired, matches),
 * deletes it, creates passwordResetSessions/{token} (10-min TTL), returns token.
 */
export const verifyOtpAndIssueResetSession = functions
  .region("us-central1")
  .https.onCall(async (data, _context) => {
    const email = (data?.email ?? "").toString().trim().toLowerCase();
    const code = (data?.code ?? "").toString();

    if (!email || !code || code.length !== 6) {
      return { ok: false, error: "Invalid parameters" };
    }

    try {
      const otpRef = db.collection("otpCodes").doc(email);
      const snap = await otpRef.get();
      if (!snap.exists) {
        return { ok: false, error: "No OTP request found. Please resend." };
      }

      const otp = snap.data() || {};
      const saved = String(otp.code ?? "");
      const expiresAtTs = otp.expiresAt;
      const expiresAt =
        typeof expiresAtTs?.toDate === "function" ?
          expiresAtTs.toDate() :
          undefined;

      if (!expiresAt || new Date() > expiresAt) {
        // Clean up expired
        await otpRef.delete();
        return { ok: false, error: "This code has expired. Please request a new one." };
      }

      if (code !== saved) {
        // Increment attempts (optional)
        await otpRef.update({
          attempts: admin.firestore.FieldValue.increment(1),
        });
        return { ok: false, error: "Invalid code. Please try again." };
      }

      // Valid → delete OTP and create reset session
      await otpRef.delete();

      const token = generateResetToken(email);
      const sessionExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

      await db.collection("passwordResetSessions").doc(token).set({
        email,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: sessionExpires,
        used: false,
      });

      return { ok: true, resetToken: token };
    } catch (err) {
      console.error(err);
      return { ok: false, error: "Internal error" };
    }
  });

export const sendOtpEmail =
  functions.region("us-central1").https.onCall(async (data) => {
    const email = (data?.email ?? "").toString().trim().toLowerCase();
    if (!email || !email.includes("@")) {
      return { ok: false, error: "Invalid email" };
    }

    const CODE_LEN = 6;
    const RESEND_COOLDOWN_MS = 60 * 1000; // 60s
    const OTP_TTL_MS = 3 * 60 * 1000; // 3m

    const otpRef = db.collection("otpCodes").doc(email);
    const snap = await otpRef.get();

    const nowMs = Date.now();
    if (snap.exists) {
      const lastSentAt = snap.get("lastSentAt")?.toDate?.() as Date | undefined;
      if (lastSentAt && nowMs - lastSentAt.getTime() < RESEND_COOLDOWN_MS) {
        const sec = Math.ceil((RESEND_COOLDOWN_MS - (nowMs - lastSentAt.getTime())) / 1000);
        return { ok: false, error: `Please wait ${sec}s before requesting a new code.` };
      }
    }

    // generate code
    // generate code
    const digits = (n: number) => {
      const b = crypto.randomBytes(n); // use imported crypto
      let out = "";
      for (let i = 0; i < n; i++) {
        out += (b[i] % 10).toString();
      }
      return out;
    };
    const code = digits(CODE_LEN);
    const expiresAt = new Date(nowMs + OTP_TTL_MS);

    // upsert OTP doc
    await otpRef.set({
      code,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastSentAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
      attempts: snap.exists ? (snap.get("attempts") ?? 0) : 0,
    }, { merge: true });

    // queue email for the Trigger Email extension
    await db.collection("mail").add({
      to: email,
      template: { name: "otp", data: { otp: code, appName: "MineChat" } },
    });

    return { ok: true };
  });

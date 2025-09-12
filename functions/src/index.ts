// import * as functions from "firebase-functions";
// import * as admin from "firebase-admin";
// import * as crypto from "crypto";
//
// if (!admin.apps.length) {
//   admin.initializeApp();
// }
// const db = admin.firestore();
//
// function generateResetToken(email: string): string {
//   const rand = crypto.randomBytes(32).toString("base64url");
//   const base = `${email}:${Date.now()}:${rand}`;
//   return crypto.createHash("sha256").update(base).digest("hex");
// }
//
// /**
//  * Callable: verifyOtpAndIssueResetSession
//  * Params: { email, code }
//  * Reads otpCodes/{email}, validates (exists, not expired, matches),
//  * deletes it, creates passwordResetSessions/{token} (10-min TTL), returns token.
//  */
// export const verifyOtpAndIssueResetSession = functions
//   .region("us-central1")
//   .https.onCall(async (data, _context) => {
//     const email = (data?.email ?? "").toString().trim().toLowerCase();
//     const code = (data?.code ?? "").toString();
//
//     if (!email || !code || code.length !== 6) {
//       return { ok: false, error: "Invalid parameters" };
//     }
//
//     try {
//       const otpRef = db.collection("otpCodes").doc(email);
//       const snap = await otpRef.get();
//       if (!snap.exists) {
//         return { ok: false, error: "No OTP request found. Please resend." };
//       }
//
//       const otp = snap.data() || {};
//       const saved = String(otp.code ?? "");
//       const expiresAtTs = otp.expiresAt;
//       const expiresAt =
//         typeof expiresAtTs?.toDate === "function" ?
//           expiresAtTs.toDate() :
//           undefined;
//
//       if (!expiresAt || new Date() > expiresAt) {
//         // Clean up expired
//         await otpRef.delete();
//         return { ok: false, error: "This code has expired. Please request a new one." };
//       }
//
//       if (code !== saved) {
//         // Increment attempts (optional)
//         await otpRef.update({
//           attempts: admin.firestore.FieldValue.increment(1),
//         });
//         return { ok: false, error: "Invalid code. Please try again." };
//       }
//
//       // Valid → delete OTP and create reset session
//       await otpRef.delete();
//
//       const token = generateResetToken(email);
//       const sessionExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 mins
//
//       await db.collection("passwordResetSessions").doc(token).set({
//         email,
//         createdAt: admin.firestore.FieldValue.serverTimestamp(),
//         expiresAt: sessionExpires,
//         used: false,
//       });
//
//       return { ok: true, resetToken: token };
//     } catch (err) {
//       console.error(err);
//       return { ok: false, error: "Internal error" };
//     }
//   });
//
// export const sendOtpEmail =
//   functions.region("us-central1").https.onCall(async (data) => {
//     const email = (data?.email ?? "").toString().trim().toLowerCase();
//     if (!email || !email.includes("@")) {
//       return { ok: false, error: "Invalid email" };
//     }
//
//     const CODE_LEN = 6;
//     const RESEND_COOLDOWN_MS = 60 * 1000; // 60s
//     const OTP_TTL_MS = 3 * 60 * 1000; // 3m
//
//     const otpRef = db.collection("otpCodes").doc(email);
//     const snap = await otpRef.get();
//
//     const nowMs = Date.now();
//     if (snap.exists) {
//       const lastSentAt = snap.get("lastSentAt")?.toDate?.() as Date | undefined;
//       if (lastSentAt && nowMs - lastSentAt.getTime() < RESEND_COOLDOWN_MS) {
//         const sec = Math.ceil((RESEND_COOLDOWN_MS - (nowMs - lastSentAt.getTime())) / 1000);
//         return { ok: false, error: `Please wait ${sec}s before requesting a new code.` };
//       }
//     }
//
//     // generate code
//     // generate code
//     const digits = (n: number) => {
//       const b = crypto.randomBytes(n); // use imported crypto
//       let out = "";
//       for (let i = 0; i < n; i++) {
//         out += (b[i] % 10).toString();
//       }
//       return out;
//     };
//     const code = digits(CODE_LEN);
//     const expiresAt = new Date(nowMs + OTP_TTL_MS);
//
//     // upsert OTP doc
//     await otpRef.set({
//       code,
//       createdAt: admin.firestore.FieldValue.serverTimestamp(),
//       lastSentAt: admin.firestore.FieldValue.serverTimestamp(),
//       expiresAt,
//       attempts: snap.exists ? (snap.get("attempts") ?? 0) : 0,
//     }, { merge: true });
//
//     // queue email for the Trigger Email extension
//     await db.collection("mail").add({
//       to: email,
//       template: { name: "otp", data: { otp: code, appName: "MineChat" } },
//     });
//
//     return { ok: true };
//   });
// ===== v1 callables (OTP flows + back-compat reset) =====
import * as functionsV1 from "firebase-functions/v1";

import * as admin from "firebase-admin";
import * as crypto from "crypto";

// ===== v2 (HTTP & Scheduler) for OpenAI & Facebook =====
import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";

// --- Firebase Admin init ---
if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

// --- Helpers ---
function generateResetToken(email: string): string {
  const rand = crypto.randomBytes(32).toString("base64url");
  const base = `${email}:${Date.now()}:${rand}`;
  return crypto.createHash("sha256").update(base).digest("hex");
}

/**
 * Callable (v1): verifyOtpAndIssueResetSession
 * Params: { email, code }
 * Behavior: exactly your old logic.
 */
export const verifyOtpAndIssueResetSession = functionsV1
  .region("us-central1")
  .https.onCall(async (data: any) => {
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

      const otp = (snap.data() || {}) as any;
      const saved = String(otp.code ?? "");
      const expiresAtTs = otp.expiresAt;
      const expiresAt =
        typeof expiresAtTs?.toDate === "function" ? expiresAtTs.toDate() : undefined;

      if (!expiresAt || new Date() > expiresAt) {
        await otpRef.delete();
        return { ok: false, error: "This code has expired. Please request a new one." };
      }

      if (code !== saved) {
        await otpRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
        return { ok: false, error: "Invalid code. Please try again." };
      }

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

/**
 * Callable (v1): sendOtpEmail
 * Params: { email }
 * Behavior: exactly your old logic.
 */
export const sendOtpEmail = functionsV1
  .region("us-central1")
  .https.onCall(async (data: any) => {
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

    const digits = (n: number) => {
      const b = crypto.randomBytes(n);
      let out = "";
      for (let i = 0; i < n; i++) out += (b[i] % 10).toString();
      return out;
    };
    const code = digits(CODE_LEN);
    const expiresAt = new Date(nowMs + OTP_TTL_MS);

    await otpRef.set(
      {
        code,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastSentAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt,
        attempts: snap.exists ? (snap.get("attempts") ?? 0) : 0,
      },
      { merge: true }
    );

    // Firestore "mail" collection (for Email extension / your mailer)
    await db.collection("mail").add({
      to: email,
      template: { name: "otp", data: { otp: code, appName: "MineChat" } },
    });

    return { ok: true };
  });

/**
 * Callable (v1): resetPasswordWithSession
 * Back-compat shim for your Flutter code.
 * Params: { email, newPassword, resetToken }
 */
export const resetPasswordWithSession = functionsV1
  .region("us-central1")
  .https.onCall(async (data: any) => {
    try {
      const email = String(data?.email || "").trim().toLowerCase();
      const newPassword = String(data?.newPassword || "").trim();
      const resetToken = String(data?.resetToken || "").trim();

      if (!email || !newPassword || newPassword.length < 6 || !resetToken) {
        return { ok: false, error: "Invalid parameters" };
      }

      // Load session doc
      const sessionRef = db.collection("passwordResetSessions").doc(resetToken);
      const snap = await sessionRef.get();
      if (!snap.exists) {
        return { ok: false, error: "Invalid or expired session" };
      }
      const s = (snap.data() ?? {}) as any;

      // Defensive reads
      const sessionEmail: string = String(s.email || "").toLowerCase();
      const used: boolean = !!s.used;
      const expiresAtRaw = s.expiresAt;
      const expiresAt: Date | null =
        typeof expiresAtRaw?.toDate === "function"
          ? expiresAtRaw.toDate()
          : expiresAtRaw instanceof Date
          ? expiresAtRaw
          : null;

      if (!sessionEmail) {
        return { ok: false, error: "Corrupt session: no email" };
      }
      if (sessionEmail !== email) {
        return { ok: false, error: "Email mismatch for this session" };
      }
      if (used) {
        return { ok: false, error: "Session already used" };
      }
      if (!expiresAt || new Date() > expiresAt) {
        await sessionRef.set(
          { used: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
          { merge: true }
        );
        return { ok: false, error: "Session expired" };
      }

      // Update password in Firebase Auth
      const userRecord = await admin.auth().getUserByEmail(email);
      await admin.auth().updateUser(userRecord.uid, { password: newPassword });

      // Mark session used
      await sessionRef.set(
        { used: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );

      return { ok: true };
    } catch (err) {
      console.error("[resetPasswordWithSession] error:", err);
      return { ok: false, error: "Internal error" };
    }
  });

// ===== v2 (HTTP + Scheduler) for OpenAI & Facebook =====

// Secrets
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");
const FB_APP_ID = defineSecret("FB_APP_ID");
const FB_APP_SECRET = defineSecret("FB_APP_SECRET");
const FB_SYSTEM_USER_TOKEN = defineSecret("FB_SYSTEM_USER_TOKEN");

/**
 * POST /apiChat
 * Body: { messages, model?, max_tokens?, temperature? }
 */
export const apiChat = onRequest(
  { region: "us-central1", cors: true, secrets: [OPENAI_API_KEY] },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const body = (req.body ?? {}) as any;
      const messages = body.messages ?? [{ role: "user", content: "Hello" }];
      const model = body.model ?? "gpt-4o-mini";
      const max_tokens = body.max_tokens ?? 500;
      const temperature = body.temperature ?? 0.7;

      const r = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${OPENAI_API_KEY.value()}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ model, messages, max_tokens, temperature }),
      });

      const data = (await r.json()) as any;
      if (!r.ok) {
        console.error("[apiChat] OpenAI error", r.status, data?.error ?? data);
        res.status(r.status).json({ error: data });
        return;
      }
      res.json(data);
    } catch (err) {
      console.error("[apiChat] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbDerivePageToken
 * Body: { pageId }
 * Uses System User token to get a Page token and stores it in Firestore.
 */
export const fbDerivePageToken = onRequest(
  { region: "us-central1", cors: true, secrets: [FB_SYSTEM_USER_TOKEN, FB_APP_ID, FB_APP_SECRET] },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const pageId = String(req.body?.pageId || "").trim();
      if (!pageId) {
        res.status(400).json({ error: "Missing pageId" });
        return;
      }

      // 1) get page token via System User token
      const url = new URL(`https://graph.facebook.com/v21.0/${pageId}`);
      url.searchParams.set("fields", "access_token");
      url.searchParams.set("access_token", FB_SYSTEM_USER_TOKEN.value());

      let r = await fetch(url);
      let data = (await r.json()) as any;
      if (!r.ok || !data?.access_token) {
        console.error("[fbDerivePageToken] failed", r.status, data);
        res.status(400).json({ error: data });
        return;
      }
      const pageAccessToken = data.access_token as string;

      // 2) debug token to check validity/expiry
      const appAccessToken = `${FB_APP_ID.value()}|${FB_APP_SECRET.value()}`;
      const debugUrl = new URL("https://graph.facebook.com/v21.0/debug_token");
      debugUrl.searchParams.set("input_token", pageAccessToken);
      debugUrl.searchParams.set("access_token", appAccessToken);

      r = await fetch(debugUrl);
      data = (await r.json()) as any;
      const debugData = (data?.data ?? {}) as any;
      const isValid = !!debugData.is_valid;
      const expiresAtSec = Number(debugData.expires_at || 0) || 0;

      // 3) persist
      const docRef = db
        .collection("integrations")
        .doc("facebook")
        .collection("pages")
        .doc(pageId);

      await docRef.set(
        {
          pageId,
          source: "system_user",
          pageAccessToken,
          isValid,
          expiresAt: expiresAtSec
            ? admin.firestore.Timestamp.fromDate(new Date(expiresAtSec * 1000))
            : null,
          checkedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      res.json({ ok: true, pageId, isValid, expiresAt: expiresAtSec });
    } catch (err) {
      console.error("[fbDerivePageToken] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbSendMessage
 * Body: { pageId, recipientId, text }
 */
export const fbSendMessage = onRequest(
  { region: "us-central1", cors: true },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const pageId = String(req.body?.pageId || "").trim();
      const recipientId = String(req.body?.recipientId || "").trim();
      const text = String(req.body?.text || "").trim();
      if (!pageId || !recipientId || !text) {
        res.status(400).json({ error: "Missing pageId/recipientId/text" });
        return;
      }

      const docRef = db
        .collection("integrations")
        .doc("facebook")
        .collection("pages")
        .doc(pageId);
      const snap = await docRef.get();
      if (!snap.exists) {
        res.status(400).json({ error: "No stored page access token; derive first." });
        return;
      }
      const cfg = (snap.data() ?? {}) as any;
      const pageAccessToken = String(cfg.pageAccessToken || "");
      if (!pageAccessToken) {
        res.status(400).json({ error: "Missing page access token" });
        return;
      }

      const msgUrl = new URL("https://graph.facebook.com/v21.0/me/messages");
      msgUrl.searchParams.set("access_token", pageAccessToken);

      const r = await fetch(msgUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          recipient: { id: recipientId },
          messaging_type: "UPDATE",
          message: { text },
        }),
      });

      const data = (await r.json()) as any;
      if (!r.ok) {
        console.error("[fbSendMessage] error", r.status, data);
        res.status(r.status).json({ error: data });
        return;
      }
      res.json({ ok: true, response: data });
    } catch (err) {
      console.error("[fbSendMessage] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * Daily check & rotate page tokens (if invalid/expiring)
 */
export const fbRotatePageToken = onSchedule(
  {
    region: "us-central1",
    schedule: "every 24 hours",
    timeZone: "UTC",
    secrets: [FB_APP_ID, FB_APP_SECRET, FB_SYSTEM_USER_TOKEN],
  },
  async () => {
    const pagesCol = db.collection("integrations").doc("facebook").collection("pages");
    const snaps = await pagesCol.get();
    const appAccessToken = `${FB_APP_ID.value()}|${FB_APP_SECRET.value()}`;

    for (const doc of snaps.docs) {
      try {
        const pageId = doc.id;
        const cfg = (doc.data() ?? {}) as any;
        const token = String(cfg.pageAccessToken || "");

        const debugUrl = new URL("https://graph.facebook.com/v21.0/debug_token");
        debugUrl.searchParams.set("input_token", token);
        debugUrl.searchParams.set("access_token", appAccessToken);

        let r = await fetch(debugUrl);
        let data = (await r.json()) as any;
        const dd = (data?.data ?? {}) as any;
        const isValid = !!dd.is_valid;
        const expiresAtSec = Number(dd.expires_at || 0) || 0;

        const needsRenew =
          !isValid || (expiresAtSec && expiresAtSec * 1000 - Date.now() < 7 * 24 * 3600 * 1000);

        if (needsRenew) {
          const tokenUrl = new URL(`https://graph.facebook.com/v21.0/${pageId}`);
          tokenUrl.searchParams.set("fields", "access_token");
          tokenUrl.searchParams.set("access_token", FB_SYSTEM_USER_TOKEN.value());

          r = await fetch(tokenUrl);
          data = (await r.json()) as any;

          if (r.ok && data?.access_token) {
            const newToken = data.access_token as string;
            await pagesCol.doc(pageId).set(
              {
                pageAccessToken: newToken,
                isValid: true,
                expiresAt: expiresAtSec
                  ? admin.firestore.Timestamp.fromDate(new Date(expiresAtSec * 1000))
                  : null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                checkedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          } else {
            await pagesCol.doc(pageId).set(
              {
                isValid: false,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                checkedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          }
        } else {
          await pagesCol.doc(pageId).set(
            {
              isValid: true,
              expiresAt: expiresAtSec
                ? admin.firestore.Timestamp.fromDate(new Date(expiresAtSec * 1000))
                : null,
              checkedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
      } catch (err) {
        console.error("[fbRotatePageToken] per-doc error", err);
      }
    }
  }
);

// ---- Facebook user-login flow (no System User required) ----

/**
 * POST /fbExchangeUserToken
 * Body: { shortLivedToken }
 */
export const fbExchangeUserToken = onRequest(
  { region: "us-central1", cors: true, secrets: [FB_APP_ID, FB_APP_SECRET] },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const short = String(req.body?.shortLivedToken || "").trim();
      if (!short) {
        res.status(400).json({ error: "Missing shortLivedToken" });
        return;
      }

      const url = new URL("https://graph.facebook.com/v21.0/oauth/access_token");
      url.searchParams.set("grant_type", "fb_exchange_token");
      url.searchParams.set("client_id", FB_APP_ID.value());
      url.searchParams.set("client_secret", FB_APP_SECRET.value());
      url.searchParams.set("fb_exchange_token", short);

      const r = await fetch(url);
      const data = (await r.json()) as Record<string, any>;
      if (!r.ok) {
        res.status(r.status).json({ error: data });
        return;
      }
      res.json({ ok: true, ...data }); // { access_token, token_type, expires_in }
    } catch (e) {
      console.error("[fbExchangeUserToken]", e);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbDebugToken
 * Body: { token }
 */
export const fbDebugToken = onRequest(
  { region: "us-central1", cors: true, secrets: [FB_APP_ID, FB_APP_SECRET] },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const token = String(req.body?.token || "").trim();
      if (!token) {
        res.status(400).json({ error: "Missing token" });
        return;
      }

      const appAccessToken = `${FB_APP_ID.value()}|${FB_APP_SECRET.value()}`;
      const url = new URL("https://graph.facebook.com/v21.0/debug_token");
      url.searchParams.set("input_token", token);
      url.searchParams.set("access_token", appAccessToken);

      const r = await fetch(url);
      const data = (await r.json()) as any;
      if (!r.ok) {
        res.status(r.status).json({ error: data });
        return;
      }
      res.json({ ok: true, data: data?.data });
    } catch (e) {
      console.error("[fbDebugToken]", e);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbGetPageTokenFromUser
 * Body: { pageId, longLivedUserToken }
 */
export const fbGetPageTokenFromUser = onRequest(
  { region: "us-central1", cors: true },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const pageId = String(req.body?.pageId || "").trim();
      const longUserToken = String(req.body?.longLivedUserToken || "").trim();
      if (!pageId || !longUserToken) {
        res.status(400).json({ error: "Missing pageId/longLivedUserToken" });
        return;
      }

      const url = new URL(`https://graph.facebook.com/v21.0/${pageId}`);
      url.searchParams.set("fields", "access_token");
      url.searchParams.set("access_token", longUserToken);

      const r = await fetch(url);
      const data = (await r.json()) as any;
      if (!r.ok || !data?.access_token) {
        res.status(400).json({ error: data });
        return;
      }
      res.json({ ok: true, pageAccessToken: data.access_token });
    } catch (e) {
      console.error("[fbGetPageTokenFromUser]", e);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbGetPagesWithTokensFromUser
 * Body: { longLivedUserToken }
 */
export const fbGetPagesWithTokensFromUser = onRequest(
  { region: "us-central1", cors: true },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const longLivedUserToken = String(req.body?.longLivedUserToken || "").trim();
      if (!longLivedUserToken) {
        res.status(400).json({ error: "Missing longLivedUserToken" });
        return;
      }

      const url = new URL("https://graph.facebook.com/v21.0/me/accounts");
      url.searchParams.set("fields", "id,name,access_token,perms");
      url.searchParams.set("access_token", longLivedUserToken);

      const r = await fetch(url);
      const data = (await r.json()) as any;
      if (!r.ok) {
        console.error("[fbGetPagesWithTokensFromUser] error", r.status, data);
        res.status(r.status).json({ error: data });
        return;
      }
      const pages = Array.isArray(data?.data) ? data.data : [];
      res.json({ ok: true, pages });
    } catch (e) {
      console.error("[fbGetPagesWithTokensFromUser]", e);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

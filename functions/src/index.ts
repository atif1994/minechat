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
 * Hourly check & refresh tokens (if expiring in next 2 hours)
 */
export const fbRefreshLongLivedTokens = onSchedule(
  {
    region: "us-central1",
    schedule: "every 1 hours",
    timeZone: "UTC",
    secrets: [FB_APP_ID, FB_APP_SECRET],
  },
  async () => {
    try {
      console.log("🔄 Starting hourly Facebook token refresh...");
      
      // Check user tokens
      const userTokenRef = db.collection("facebook_tokens").doc("user_token");
      const userTokenDoc = await userTokenRef.get();
      
      if (userTokenDoc.exists) {
        const userTokenData = userTokenDoc.data() as any;
        const longLivedToken = userTokenData.longLivedUserToken;
        const expiresAt = userTokenData.expiresAt?.toDate();
        
        // Check if token expires in next 2 hours
        if (expiresAt && expiresAt.getTime() - Date.now() < 2 * 3600 * 1000) {
          console.log("⚠️ Long-lived user token expires soon, attempting refresh...");
          
          try {
            // Try to refresh the long-lived token
            const refreshUrl = new URL("https://graph.facebook.com/v21.0/oauth/access_token");
            refreshUrl.searchParams.set("grant_type", "fb_exchange_token");
            refreshUrl.searchParams.set("client_id", FB_APP_ID.value());
            refreshUrl.searchParams.set("client_secret", FB_APP_SECRET.value());
            refreshUrl.searchParams.set("fb_exchange_token", longLivedToken);

            const refreshResponse = await fetch(refreshUrl);
            const refreshData = (await refreshResponse.json()) as any;
            
            if (refreshResponse.ok && refreshData.access_token) {
              // Update with new token
              await userTokenRef.set({
                longLivedUserToken: refreshData.access_token,
                expiresAt: refreshData.expires_in ? 
                  admin.firestore.Timestamp.fromDate(new Date(Date.now() + refreshData.expires_in * 1000)) : 
                  null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              });
              
              console.log("✅ Long-lived user token refreshed successfully");
            } else {
              console.log("❌ Failed to refresh long-lived token:", refreshData);
            }
          } catch (err) {
            console.error("❌ Error refreshing long-lived token:", err);
          }
        } else {
          console.log("✅ Long-lived user token is still valid");
        }
      }

      // Check page tokens (these should never expire, but let's verify)
      const pagesCol = db.collection("integrations").doc("facebook").collection("pages");
      const pagesSnapshot = await pagesCol.get();
      const appAccessToken = `${FB_APP_ID.value()}|${FB_APP_SECRET.value()}`;

      for (const doc of pagesSnapshot.docs) {
        try {
          const pageId = doc.id;
          const pageData = doc.data();
          const pageToken = pageData.pageAccessToken;

          // Debug the page token
          const debugUrl = new URL("https://graph.facebook.com/v21.0/debug_token");
          debugUrl.searchParams.set("input_token", pageToken);
          debugUrl.searchParams.set("access_token", appAccessToken);

          const debugResponse = await fetch(debugUrl);
          const debugData = (await debugResponse.json()) as any;
          const debugInfo = (debugData?.data ?? {}) as any;
          const isValid = !!debugInfo.is_valid;

          await pagesCol.doc(pageId).set({
            isValid,
            checkedAt: admin.firestore.FieldValue.serverTimestamp(),
          }, { merge: true });

          if (!isValid) {
            console.log(`⚠️ Page token for ${pageId} is invalid`);
          }
        } catch (err) {
          console.error(`❌ Error checking page token ${doc.id}:`, err);
        }
      }

      console.log("✅ Hourly Facebook token refresh completed");
    } catch (err) {
      console.error("❌ Error in daily token refresh:", err);
    }
  }
);

/**
 * Daily check & rotate page tokens (if invalid/expiring) - Legacy function
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

/**
 * POST /fbExchangeForLongLivedToken
 * Body: { shortLivedToken }
 * Exchanges short-lived token for long-lived token (60 days)
 */
export const fbExchangeForLongLivedToken = onRequest(
  { region: "us-central1", cors: true, secrets: [FB_APP_ID, FB_APP_SECRET] },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      
      const shortLivedToken = String(req.body?.shortLivedToken || "").trim();
      if (!shortLivedToken) {
        res.status(400).json({ error: "Missing shortLivedToken" });
        return;
      }

      // Exchange short-lived token for long-lived token
      const exchangeUrl = new URL("https://graph.facebook.com/v21.0/oauth/access_token");
      exchangeUrl.searchParams.set("grant_type", "fb_exchange_token");
      exchangeUrl.searchParams.set("client_id", FB_APP_ID.value());
      exchangeUrl.searchParams.set("client_secret", FB_APP_SECRET.value());
      exchangeUrl.searchParams.set("fb_exchange_token", shortLivedToken);

      const exchangeResponse = await fetch(exchangeUrl);
      const exchangeData = (await exchangeResponse.json()) as any;
      
      if (!exchangeResponse.ok) {
        console.error("[fbExchangeForLongLivedToken] exchange failed", exchangeResponse.status, exchangeData);
        res.status(400).json({ error: "Token exchange failed", details: exchangeData });
        return;
      }

      const longLivedToken = exchangeData.access_token;
      const expiresIn = exchangeData.expires_in; // seconds

      // Get user's pages with the long-lived token
      const pagesUrl = new URL("https://graph.facebook.com/v21.0/me/accounts");
      pagesUrl.searchParams.set("fields", "id,name,access_token,category");
      pagesUrl.searchParams.set("access_token", longLivedToken);

      const pagesResponse = await fetch(pagesUrl);
      const pagesData = (await pagesResponse.json()) as any;
      
      if (!pagesResponse.ok) {
        console.error("[fbExchangeForLongLivedToken] pages failed", pagesResponse.status, pagesData);
        res.status(400).json({ error: "Failed to fetch pages", details: pagesData });
        return;
      }

      const pages = pagesData.data || [];
      if (pages.length === 0) {
        res.status(400).json({ error: "No Facebook pages found" });
        return;
      }

      // Store the long-lived user token and page tokens
      const userTokenRef = db.collection("facebook_tokens").doc("user_token");
      await userTokenRef.set({
        longLivedUserToken: longLivedToken,
        expiresAt: expiresIn ? admin.firestore.Timestamp.fromDate(new Date(Date.now() + expiresIn * 1000)) : null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Store each page token
      for (const page of pages) {
        const pageRef = db
          .collection("integrations")
          .doc("facebook")
          .collection("pages")
          .doc(page.id);
        
        await pageRef.set({
          pageId: page.id,
          pageName: page.name,
          pageCategory: page.category || "",
          pageAccessToken: page.access_token, // Never expires!
          userToken: longLivedToken,
          source: "long_lived_exchange",
          isValid: true,
          expiresAt: null, // Page tokens never expire
          checkedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      res.json({
        ok: true,
        message: "Successfully exchanged for long-lived token and stored page tokens",
        pagesCount: pages.length,
        pages: pages.map((p: any) => ({ id: p.id, name: p.name })),
        userTokenExpiresIn: expiresIn,
      });

    } catch (err) {
      console.error("[fbExchangeForLongLivedToken] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbDeleteConversation
 * Body: { pageId, conversationId, deleteType? }
 * Deletes Facebook conversation and messages
 */
export const fbDeleteConversation = onRequest(
  { region: "us-central1", cors: true },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const pageId = String(req.body?.pageId || "").trim();
      const conversationId = String(req.body?.conversationId || "").trim();
      const deleteType = String(req.body?.deleteType || "archive").trim(); // "delete" or "archive"
      
      if (!pageId || !conversationId) {
        res.status(400).json({ error: "Missing pageId/conversationId" });
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

      if (deleteType === "archive") {
        // Archive the conversation (soft delete)
        const archiveUrl = new URL(`https://graph.facebook.com/v23.0/${conversationId}`);
        archiveUrl.searchParams.set("access_token", pageAccessToken);

        const r = await fetch(archiveUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            is_archived: true,
          }),
        });

        const data = (await r.json()) as any;
        if (!r.ok) {
          console.error("[fbDeleteConversation] archive error", r.status, data);
          res.status(r.status).json({ error: data });
          return;
        }
        res.json({ ok: true, type: "archived", response: data });
      } else {
        // Hard delete - get all messages and delete them
        const messagesUrl = new URL(`https://graph.facebook.com/v23.0/${conversationId}/messages`);
        messagesUrl.searchParams.set("access_token", pageAccessToken);
        messagesUrl.searchParams.set("fields", "id");
        messagesUrl.searchParams.set("limit", "100");

        const messagesResponse = await fetch(messagesUrl);
        const messagesData = (await messagesResponse.json()) as any;
        
        if (!messagesResponse.ok) {
          console.error("[fbDeleteConversation] get messages error", messagesResponse.status, messagesData);
          res.status(messagesResponse.status).json({ error: messagesData });
          return;
        }

        const messages = messagesData.data || [];
        let deletedCount = 0;
        const errors: string[] = [];

        // Check if we have permission to delete messages
        if (messages.length > 0) {
          // Try to delete the first message to check permissions
          const testMessage = messages[0];
          const testDeleteUrl = new URL(`https://graph.facebook.com/v23.0/${testMessage.id}`);
          testDeleteUrl.searchParams.set("access_token", pageAccessToken);

          const testDeleteResponse = await fetch(testDeleteUrl, {
            method: "DELETE",
          });

          if (!testDeleteResponse.ok) {
            const testErrorData = (await testDeleteResponse.json()) as any;
            if (testErrorData.error?.code === 10) {
              // Permission denied - Facebook doesn't allow message deletion
              res.json({ 
                ok: false, 
                type: "permission_denied", 
                message: "Facebook does not allow deleting messages from conversations. This is a Facebook platform limitation.",
                totalMessages: messages.length,
                suggestion: "Consider archiving the conversation instead."
              });
              return;
            }
          }
        }

        // Delete each message
        for (const message of messages) {
          const deleteUrl = new URL(`https://graph.facebook.com/v23.0/${message.id}`);
          deleteUrl.searchParams.set("access_token", pageAccessToken);

          const deleteResponse = await fetch(deleteUrl, {
            method: "DELETE",
          });

          if (deleteResponse.ok) {
            deletedCount++;
          } else {
            const errorData = (await deleteResponse.json()) as any;
            errors.push(`Message ${message.id}: ${errorData.error?.message || "Unknown error"}`);
          }
        }

        res.json({ 
          ok: true, 
          type: "deleted", 
          deletedCount, 
          totalMessages: messages.length,
          errors: errors.length > 0 ? errors : undefined
        });
      }
    } catch (err) {
      console.error("[fbDeleteConversation] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbStorePageToken
 * Body: { pageAccessToken, pageId?, source? }
 * Stores a Facebook page access token in Firestore with validation
 */
export const fbStorePageToken = onRequest(
  { region: "us-central1", cors: true, secrets: [FB_APP_ID, FB_APP_SECRET] },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      const pageAccessToken = String(req.body?.pageAccessToken || "").trim();
      const pageId = String(req.body?.pageId || "").trim();
      const source = String(req.body?.source || "manual").trim();
      
      if (!pageAccessToken) {
        res.status(400).json({ error: "Missing pageAccessToken" });
        return;
      }

      // 1) Debug token to check validity and get page info
      const appAccessToken = `${FB_APP_ID.value()}|${FB_APP_SECRET.value()}`;
      const debugUrl = new URL("https://graph.facebook.com/v21.0/debug_token");
      debugUrl.searchParams.set("input_token", pageAccessToken);
      debugUrl.searchParams.set("access_token", appAccessToken);

      let r = await fetch(debugUrl);
      let data = (await r.json()) as any;
      
      if (!r.ok) {
        console.error("[fbStorePageToken] debug failed", r.status, data);
        res.status(400).json({ error: "Invalid token or debug failed", details: data });
        return;
      }

      const debugData = (data?.data ?? {}) as any;
      const isValid = !!debugData.is_valid;
      const expiresAtSec = Number(debugData.expires_at || 0) || 0;
      const tokenPageId = String(debugData.profile_id || pageId || "");

      if (!isValid) {
        res.status(400).json({ error: "Token is invalid", debugData });
        return;
      }

      // 2) Get page info if we have a page ID
      let pageInfo = {};
      if (tokenPageId) {
        const pageUrl = new URL(`https://graph.facebook.com/v21.0/${tokenPageId}`);
        pageUrl.searchParams.set("fields", "id,name,category");
        pageUrl.searchParams.set("access_token", pageAccessToken);

        r = await fetch(pageUrl);
        if (r.ok) {
          const pageData = (await r.json()) as any;
          pageInfo = {
            pageName: pageData.name || "",
            pageCategory: pageData.category || "",
          };
        }
      }

      // 3) Store in Firestore
      const docRef = db
        .collection("integrations")
        .doc("facebook")
        .collection("pages")
        .doc(tokenPageId || "unknown");

      await docRef.set(
        {
          pageId: tokenPageId,
          source,
          pageAccessToken,
          isValid,
          expiresAt: expiresAtSec
            ? admin.firestore.Timestamp.fromDate(new Date(expiresAtSec * 1000))
            : null,
          checkedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          ...pageInfo,
        },
        { merge: true }
      );

      res.json({ 
        ok: true, 
        pageId: tokenPageId, 
        isValid, 
        expiresAt: expiresAtSec,
        message: "Page access token stored successfully"
      });
    } catch (err) {
      console.error("[fbStorePageToken] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * POST /fbConnectWithStoredToken
 * Body: { action, userId }
 * Uses stored Facebook token to connect and load chats securely
 */
export const fbConnectWithStoredToken = onRequest(
  { region: "us-central1", cors: true },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({ error: "Method Not Allowed" });
        return;
      }
      
      const action = String(req.body?.action || "").trim();
      const userId = String(req.body?.userId || "").trim();
      
      if (!action || !userId) {
        res.status(400).json({ error: "Missing action or userId" });
        return;
      }

      if (action !== "connect_and_load_chats") {
        res.status(400).json({ error: "Invalid action" });
        return;
      }

      // Get the stored page access token from Firestore
      const pagesCollection = db
        .collection("integrations")
        .doc("facebook")
        .collection("pages");

      const pagesSnapshot = await pagesCollection.get();
      
      if (pagesSnapshot.empty) {
        res.status(404).json({ error: "No Facebook page tokens found" });
        return;
      }

      // Use the first available page token
      const firstPageDoc = pagesSnapshot.docs[0];
      const pageData = firstPageDoc.data();
      
      const pageId = pageData.pageId;
      const pageAccessToken = pageData.pageAccessToken;
      const pageName = pageData.pageName || "Facebook Page";
      
      if (!pageAccessToken) {
        res.status(400).json({ error: "No valid page access token found" });
        return;
      }

      // Update user's channel settings to mark Facebook as connected
      const userChannelSettings = db.collection("channel_settings").doc(userId);
      await userChannelSettings.set({
        isFacebookConnected: true,
        facebookPageId: pageId,
        facebookPageName: pageName,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Get conversations using the stored token with more detailed fields
      const conversationsUrl = new URL(`https://graph.facebook.com/v21.0/${pageId}/conversations`);
      conversationsUrl.searchParams.set("fields", "id,updated_time,message_count,unread_count,participants,can_reply");
      conversationsUrl.searchParams.set("access_token", pageAccessToken);

      const conversationsResponse = await fetch(conversationsUrl);
      
      if (!conversationsResponse.ok) {
        console.error("[fbConnectWithStoredToken] conversations failed", conversationsResponse.status);
        res.status(400).json({ error: "Failed to fetch conversations" });
        return;
      }

      const conversationsData = (await conversationsResponse.json()) as any;
      const conversations = conversationsData.data || [];

      // Process conversations to get real user data (optimized with parallel processing)
      const enhancedConversations = [];
      console.log(`🚀 Processing ${conversations.length} conversations in parallel...`);
      
      // Process conversations in parallel with timeout
      const conversationPromises = conversations.map(async (conv: any) => {
        try {
          console.log(`📞 Processing conversation: ${conv.id}`);
          
          // Get user profile information
          let userProfile = null;
          let lastMessage = null;
          
          if (conv.participants && conv.participants.data && conv.participants.data.length > 0) {
            const participant = conv.participants.data[0];
            const userId = participant.id;
            
            // Parallel fetch for profile and messages
            const [profileResult, messageResult] = await Promise.allSettled([
              // Get user profile with timeout
              fetch(`https://graph.facebook.com/v21.0/${userId}?fields=id,name,picture&access_token=${pageAccessToken}`, {
                signal: AbortSignal.timeout(5000) // 5 second timeout
              }),
              // Get last message with timeout
              fetch(`https://graph.facebook.com/v21.0/${conv.id}/messages?fields=id,message,from,created_time&limit=1&access_token=${pageAccessToken}`, {
                signal: AbortSignal.timeout(5000) // 5 second timeout
              })
            ]);
            
            // Process profile result
            if (profileResult.status === 'fulfilled' && profileResult.value.ok) {
              try {
                userProfile = (await profileResult.value.json()) as any;
                console.log(`✅ Got profile for ${userId}: ${userProfile.name}`);
              } catch (e) {
                console.log(`⚠️ Could not parse profile for ${userId}: ${e}`);
              }
            } else {
              console.log(`⚠️ Could not get profile for ${userId}: ${profileResult.status}`);
            }
            
            // Process message result
            if (messageResult.status === 'fulfilled' && messageResult.value.ok) {
              try {
                const messagesData = (await messageResult.value.json()) as any;
                if (messagesData.data && messagesData.data.length > 0) {
                  lastMessage = messagesData.data[0];
                  console.log(`✅ Got last message for ${conv.id}`);
                }
              } catch (e) {
                console.log(`⚠️ Could not parse messages for ${conv.id}: ${e}`);
              }
            } else {
              console.log(`⚠️ Could not get messages for ${conv.id}: ${messageResult.status}`);
            }
          }
          
          return {
            id: `fb_${conv.id}`,
            conversationId: conv.id,
            pageId: pageId,
            lastUpdate: conv.updated_time,
            messageCount: conv.message_count || 0,
            unreadCount: conv.unread_count || 0,
            userName: userProfile?.name || `Facebook User ${conv.id}`,
            userProfilePicture: userProfile?.picture?.data?.url || null,
            lastMessage: lastMessage?.message || "No messages yet",
            lastMessageTime: lastMessage?.created_time || conv.updated_time,
            canReply: conv.can_reply || false,
          };
          
        } catch (e) {
          console.error(`❌ Error processing conversation ${conv.id}: ${e}`);
          // Fallback to basic data
          return {
            id: `fb_${conv.id}`,
            conversationId: conv.id,
            pageId: pageId,
            lastUpdate: conv.updated_time,
            messageCount: conv.message_count || 0,
            unreadCount: conv.unread_count || 0,
            userName: `Facebook User ${conv.id}`,
            userProfilePicture: null,
            lastMessage: "No messages yet",
            lastMessageTime: conv.updated_time,
            canReply: false,
          };
        }
      });
      
      // Wait for all conversations to be processed
      const results = await Promise.allSettled(conversationPromises);
      
      // Collect successful results
      for (const result of results) {
        if (result.status === 'fulfilled') {
          enhancedConversations.push(result.value);
        }
      }
      
      console.log(`✅ Successfully processed ${enhancedConversations.length}/${conversations.length} conversations`);

      // Store enhanced conversations in user's chat data
      const userChatsRef = db.collection("user_chats").doc(userId);
      const chatData = {
        facebookChats: enhancedConversations,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      };

      await userChatsRef.set(chatData, { merge: true });

      res.json({
        ok: true,
        pageId: pageId,
        pageName: pageName,
        conversationsCount: conversations.length,
        message: "Successfully connected and loaded Facebook chats"
      });

    } catch (err) {
      console.error("[fbConnectWithStoredToken] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

/**
 * Facebook Webhook for real-time message updates
 * GET /facebookWebhook - Webhook verification
 * POST /facebookWebhook - Handle incoming messages
 */
export const facebookWebhook = onRequest(
  { region: "us-central1", cors: true },
  async (req, res) => {
    try {
      if (req.method === "GET") {
        // Webhook verification
        const mode = req.query['hub.mode'];
        const token = req.query['hub.verify_token'];
        const challenge = req.query['hub.challenge'];

        const VERIFY_TOKEN = 'your_verify_token_here'; // Change this to your actual verify token

        if (mode === 'subscribe' && token === VERIFY_TOKEN) {
          console.log('✅ Facebook webhook verified');
          res.status(200).send(challenge);
        } else {
          console.log('❌ Facebook webhook verification failed');
          res.sendStatus(403);
        }
        return;
      }

      if (req.method === "POST") {
        // Handle incoming messages
        const body = req.body;

        if (body.object === 'page') {
          // Process each entry
          for (const entry of body.entry) {
            const pageId = entry.id;
            // const timeOfEvent = entry.time;

            // Process each messaging event
            if (entry.messaging) {
              for (const event of entry.messaging) {
                if (event.message && !event.message.is_echo) {
                  // This is a message from a user
                  await handleIncomingMessage(event, pageId);
                } else if (event.delivery) {
                  // Message delivery confirmation
                  console.log('📬 Message delivered:', event.delivery);
                } else if (event.read) {
                  // Message read confirmation
                  console.log('👁️ Message read:', event.read);
                }
              }
            }
          }

          res.status(200).send('EVENT_RECEIVED');
        } else {
          res.sendStatus(404);
        }
        return;
      }

      res.status(405).json({ error: "Method Not Allowed" });
    } catch (err) {
      console.error("[facebookWebhook] exception", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

// Helper function to handle incoming messages
async function handleIncomingMessage(event: any, pageId: string) {
  try {
    const senderId = event.sender.id;
    const recipientId = event.recipient.id;
    const message = event.message;
    const timestamp = event.timestamp;

    console.log('📨 New message received:', {
      senderId,
      recipientId,
      message: message.text,
      timestamp
    });

    // Get the conversation ID (thread ID)
    const conversationId = event.message?.thread_id || `t_${senderId}_${pageId}`;

    // Find the user who owns this page
    const userQuery = await db
      .collection('channel_settings')
      .where('facebookPageId', '==', pageId)
      .limit(1)
      .get();

    if (userQuery.empty) {
      console.log('❌ No user found for page:', pageId);
      return;
    }

    const userDoc = userQuery.docs[0];
    const userId = userDoc.id;

    // Store the message in Firebase for real-time updates
    await db
      .collection('user_messages')
      .doc(userId)
      .collection('messages')
      .add({
        conversationId: conversationId,
        text: message.text || '',
        isFromUser: true,
        platform: 'Facebook',
        senderId: senderId,
        senderName: `Facebook User ${senderId}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: new Date().toISOString(),
        facebookMessageId: message.mid,
        pageId: pageId,
      });

    // Update conversation info
    await db
      .collection('user_conversations')
      .doc(userId)
      .collection('conversations')
      .doc(conversationId)
      .set({
        conversationId: conversationId,
        contactName: `Facebook User ${senderId}`,
        lastMessage: message.text || '',
        platform: 'Facebook',
        unreadCount: admin.firestore.FieldValue.increment(1),
        lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: new Date().toISOString(),
        pageId: pageId,
        senderId: senderId,
      }, { merge: true });

    console.log('✅ Message stored for real-time updates');

  } catch (error) {
    console.error('❌ Error handling incoming message:', error);
  }
}

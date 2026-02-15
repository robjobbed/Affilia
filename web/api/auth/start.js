const { serializeCookie, setCookies } = require("./_lib/cookies");
const { randomString, buildAuthorizationUrl } = require("./_lib/providers");

const OAUTH_STATE_COOKIE = "affilia_oauth_state";
const OAUTH_PROVIDER_COOKIE = "affilia_oauth_provider";
const OAUTH_CODE_VERIFIER_COOKIE = "affilia_oauth_code_verifier";

module.exports = async function handler(req, res) {
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method Not Allowed" });
    return;
  }

  const provider = String(req.query.provider || "").toLowerCase();
  if (!provider) {
    res.status(400).json({ error: "Missing provider query parameter" });
    return;
  }

  try {
    const state = randomString(16);
    const codeVerifier = randomString(32);
    const { url } = buildAuthorizationUrl(provider, req, state, codeVerifier);

    const secure = (req.headers["x-forwarded-proto"] || "https") === "https";

    setCookies(res, [
      serializeCookie(OAUTH_STATE_COOKIE, state, {
        httpOnly: true,
        secure,
        sameSite: "Lax",
        path: "/",
        maxAge: 600
      }),
      serializeCookie(OAUTH_PROVIDER_COOKIE, provider, {
        httpOnly: true,
        secure,
        sameSite: "Lax",
        path: "/",
        maxAge: 600
      }),
      serializeCookie(OAUTH_CODE_VERIFIER_COOKIE, codeVerifier, {
        httpOnly: true,
        secure,
        sameSite: "Lax",
        path: "/",
        maxAge: 600
      })
    ]);

    res.writeHead(302, { Location: url });
    res.end();
  } catch (error) {
    res.status(400).json({ error: error.message || "OAuth start failed" });
  }
};

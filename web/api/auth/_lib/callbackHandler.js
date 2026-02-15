const { parseCookies, serializeCookie, setCookies } = require("./cookies");
const { getProviderConfig } = require("./providers");
const { createSessionToken, SESSION_COOKIE, SESSION_MAX_AGE_SECONDS } = require("./session");

const OAUTH_STATE_COOKIE = "affilia_oauth_state";
const OAUTH_PROVIDER_COOKIE = "affilia_oauth_provider";
const OAUTH_CODE_VERIFIER_COOKIE = "affilia_oauth_code_verifier";

function redirect(res, location) {
  res.writeHead(302, { Location: location });
  res.end();
}

function toErrorLocation(message) {
  const safe = encodeURIComponent(message || "OAuth callback failed");
  return `/?auth_error=${safe}`;
}

async function handleOAuthCallback(req, res, provider) {
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method Not Allowed" });
    return;
  }

  const cookies = parseCookies(req.headers.cookie || "");
  const expectedState = cookies[OAUTH_STATE_COOKIE];
  const expectedProvider = cookies[OAUTH_PROVIDER_COOKIE];
  const codeVerifier = cookies[OAUTH_CODE_VERIFIER_COOKIE];

  const { code, state, error, error_description: errorDescription } = req.query;

  const secure = (req.headers["x-forwarded-proto"] || "https") === "https";
  setCookies(res, [
    serializeCookie(OAUTH_STATE_COOKIE, "", { httpOnly: true, secure, sameSite: "Lax", path: "/", maxAge: 0 }),
    serializeCookie(OAUTH_PROVIDER_COOKIE, "", { httpOnly: true, secure, sameSite: "Lax", path: "/", maxAge: 0 }),
    serializeCookie(OAUTH_CODE_VERIFIER_COOKIE, "", { httpOnly: true, secure, sameSite: "Lax", path: "/", maxAge: 0 })
  ]);

  if (error) {
    redirect(res, toErrorLocation(errorDescription || String(error)));
    return;
  }

  if (!code || !state) {
    redirect(res, toErrorLocation("Missing OAuth code or state"));
    return;
  }

  if (!expectedState || state !== expectedState) {
    redirect(res, toErrorLocation("Invalid OAuth state"));
    return;
  }

  if (!expectedProvider || expectedProvider !== provider) {
    redirect(res, toErrorLocation("OAuth provider mismatch"));
    return;
  }

  try {
    const config = getProviderConfig(provider, req);
    if (!config || !config.clientId || !config.clientSecret) {
      throw new Error(`${provider} OAuth is not configured`);
    }

    const tokenData = await config.exchangeCode({
      code: String(code),
      redirectUri: config.redirectUri,
      codeVerifier
    });

    const accessToken = tokenData.access_token;
    if (!accessToken) {
      throw new Error("Provider did not return an access token");
    }

    const profile = await config.fetchProfile(accessToken);

    if (!profile.providerUserId) {
      throw new Error("Unable to fetch account profile from provider");
    }

    const sessionToken = createSessionToken({
      provider,
      providerUserId: profile.providerUserId,
      username: profile.username || profile.displayName || `${provider}_user`,
      displayName: profile.displayName || profile.username || `${provider} user`,
      avatarUrl: profile.avatarUrl || null,
      email: profile.email || null
    });

    setCookies(res, [
      serializeCookie(SESSION_COOKIE, sessionToken, {
        httpOnly: true,
        secure,
        sameSite: "Lax",
        path: "/",
        maxAge: SESSION_MAX_AGE_SECONDS
      })
    ]);

    redirect(res, "/?auth=success");
  } catch (oauthError) {
    redirect(res, toErrorLocation(oauthError.message || "OAuth callback failed"));
  }
}

module.exports = {
  handleOAuthCallback
};

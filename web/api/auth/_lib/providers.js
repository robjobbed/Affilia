const crypto = require("crypto");

function getOrigin(req) {
  const protocol = req.headers["x-forwarded-proto"] || "https";
  const host = req.headers["x-forwarded-host"] || req.headers.host;
  return `${protocol}://${host}`;
}

function randomString(length = 48) {
  return crypto.randomBytes(length).toString("hex");
}

function sha256Base64Url(value) {
  return crypto
    .createHash("sha256")
    .update(value)
    .digest("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

async function requestJson(url, options = {}) {
  const response = await fetch(url, options);
  const text = await response.text();

  let data;
  try {
    data = JSON.parse(text);
  } catch {
    data = { raw: text };
  }

  if (!response.ok) {
    const message = data.error_description || data.error?.message || data.error || JSON.stringify(data);
    throw new Error(`OAuth request failed (${response.status}): ${message}`);
  }

  return data;
}

function getProviderConfig(provider, req) {
  const origin = getOrigin(req);

  const providers = {
    x: {
      id: "x",
      label: "X",
      authUrl: "https://twitter.com/i/oauth2/authorize",
      tokenUrl: "https://api.x.com/2/oauth2/token",
      scope: "users.read tweet.read offline.access",
      clientId: process.env.X_CLIENT_ID,
      clientSecret: process.env.X_CLIENT_SECRET,
      redirectUri: process.env.X_REDIRECT_URI || `${origin}/api/auth/callback/x`,
      usesPkce: true,
      async exchangeCode({ code, redirectUri, codeVerifier }) {
        const form = new URLSearchParams({
          grant_type: "authorization_code",
          code,
          redirect_uri: redirectUri,
          client_id: this.clientId,
          code_verifier: codeVerifier
        });

        return requestJson(this.tokenUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            Authorization: `Basic ${Buffer.from(`${this.clientId}:${this.clientSecret}`).toString("base64")}`
          },
          body: form
        });
      },
      async fetchProfile(accessToken) {
        const data = await requestJson(
          "https://api.x.com/2/users/me?user.fields=profile_image_url,verified,name,username",
          {
            headers: {
              Authorization: `Bearer ${accessToken}`
            }
          }
        );

        return {
          providerUserId: data.data?.id,
          username: data.data?.username,
          displayName: data.data?.name,
          avatarUrl: data.data?.profile_image_url,
          email: null
        };
      }
    },
    instagram: {
      id: "instagram",
      label: "Instagram",
      authUrl: "https://api.instagram.com/oauth/authorize",
      tokenUrl: "https://api.instagram.com/oauth/access_token",
      scope: "user_profile,user_media",
      clientId: process.env.IG_CLIENT_ID,
      clientSecret: process.env.IG_CLIENT_SECRET,
      redirectUri: process.env.IG_REDIRECT_URI || `${origin}/api/auth/callback/instagram`,
      usesPkce: false,
      async exchangeCode({ code, redirectUri }) {
        const form = new URLSearchParams({
          client_id: this.clientId,
          client_secret: this.clientSecret,
          grant_type: "authorization_code",
          redirect_uri: redirectUri,
          code
        });

        return requestJson(this.tokenUrl, {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
          body: form
        });
      },
      async fetchProfile(accessToken) {
        const data = await requestJson(
          `https://graph.instagram.com/me?fields=id,username,account_type,media_count&access_token=${encodeURIComponent(
            accessToken
          )}`
        );

        return {
          providerUserId: data.id,
          username: data.username,
          displayName: data.username,
          avatarUrl: null,
          email: null
        };
      }
    },
    facebook: {
      id: "facebook",
      label: "Facebook",
      authUrl: "https://www.facebook.com/v19.0/dialog/oauth",
      tokenUrl: "https://graph.facebook.com/v19.0/oauth/access_token",
      scope: "public_profile,email",
      clientId: process.env.FB_CLIENT_ID,
      clientSecret: process.env.FB_CLIENT_SECRET,
      redirectUri: process.env.FB_REDIRECT_URI || `${origin}/api/auth/callback/facebook`,
      usesPkce: false,
      async exchangeCode({ code, redirectUri }) {
        const url = new URL(this.tokenUrl);
        url.searchParams.set("client_id", this.clientId);
        url.searchParams.set("client_secret", this.clientSecret);
        url.searchParams.set("redirect_uri", redirectUri);
        url.searchParams.set("code", code);

        return requestJson(url.toString());
      },
      async fetchProfile(accessToken) {
        const data = await requestJson(
          `https://graph.facebook.com/me?fields=id,name,picture.type(large),email&access_token=${encodeURIComponent(accessToken)}`
        );

        return {
          providerUserId: data.id,
          username: data.name,
          displayName: data.name,
          avatarUrl: data.picture?.data?.url || null,
          email: data.email || null
        };
      }
    },
    tiktok: {
      id: "tiktok",
      label: "TikTok",
      authUrl: "https://www.tiktok.com/v2/auth/authorize/",
      tokenUrl: "https://open.tiktokapis.com/v2/oauth/token/",
      scope: "user.info.basic",
      clientId: process.env.TIKTOK_CLIENT_KEY,
      clientSecret: process.env.TIKTOK_CLIENT_SECRET,
      redirectUri: process.env.TIKTOK_REDIRECT_URI || `${origin}/api/auth/callback/tiktok`,
      usesPkce: false,
      async exchangeCode({ code, redirectUri }) {
        const form = new URLSearchParams({
          client_key: this.clientId,
          client_secret: this.clientSecret,
          code,
          grant_type: "authorization_code",
          redirect_uri: redirectUri
        });

        return requestJson(this.tokenUrl, {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
          body: form
        });
      },
      async fetchProfile(accessToken) {
        const data = await requestJson("https://open.tiktokapis.com/v2/user/info/?fields=open_id,display_name,avatar_url,username", {
          headers: {
            Authorization: `Bearer ${accessToken}`
          }
        });

        const user = data.data?.user || {};
        return {
          providerUserId: user.open_id,
          username: user.username || user.display_name,
          displayName: user.display_name || user.username,
          avatarUrl: user.avatar_url || null,
          email: null
        };
      }
    }
  };

  return providers[provider] || null;
}

function getAllProviderStatus(req) {
  const ids = ["x", "instagram", "facebook", "tiktok"];
  return ids.map((id) => {
    const provider = getProviderConfig(id, req);
    const enabled = Boolean(provider?.clientId && provider?.clientSecret);
    return {
      id,
      label: provider?.label || id,
      enabled,
      reason: enabled ? null : `Missing ${id.toUpperCase()} OAuth environment variables`
    };
  });
}

function buildAuthorizationUrl(provider, req, state, codeVerifier) {
  const cfg = getProviderConfig(provider, req);
  if (!cfg) throw new Error("Unsupported provider");

  if (!cfg.clientId || !cfg.clientSecret) {
    throw new Error(`Provider ${cfg.label} is not configured on server`);
  }

  const url = new URL(cfg.authUrl);
  url.searchParams.set("response_type", "code");
  url.searchParams.set(cfg.id === "tiktok" ? "client_key" : "client_id", cfg.clientId);
  url.searchParams.set("redirect_uri", cfg.redirectUri);
  url.searchParams.set("scope", cfg.scope);
  url.searchParams.set("state", state);

  if (cfg.id === "instagram") {
    url.searchParams.set("response_type", "code");
  }

  if (cfg.usesPkce) {
    const challenge = sha256Base64Url(codeVerifier);
    url.searchParams.set("code_challenge", challenge);
    url.searchParams.set("code_challenge_method", "S256");
  }

  return { url: url.toString(), config: cfg };
}

module.exports = {
  randomString,
  getProviderConfig,
  getAllProviderStatus,
  buildAuthorizationUrl
};

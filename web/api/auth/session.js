const { parseCookies } = require("./_lib/cookies");
const { SESSION_COOKIE, verifySessionToken } = require("./_lib/session");

module.exports = async function handler(req, res) {
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method Not Allowed" });
    return;
  }

  const cookies = parseCookies(req.headers.cookie || "");
  const token = cookies[SESSION_COOKIE];
  const session = verifySessionToken(token);

  if (!session) {
    res.status(200).json({ authenticated: false, user: null });
    return;
  }

  res.status(200).json({
    authenticated: true,
    user: {
      provider: session.provider,
      providerUserId: session.providerUserId,
      username: session.username,
      displayName: session.displayName,
      avatarUrl: session.avatarUrl,
      email: session.email
    }
  });
};

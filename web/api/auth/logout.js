const { serializeCookie } = require("./_lib/cookies");
const { SESSION_COOKIE } = require("./_lib/session");

module.exports = async function handler(req, res) {
  if (!["POST", "GET"].includes(req.method)) {
    res.status(405).json({ error: "Method Not Allowed" });
    return;
  }

  const secure = (req.headers["x-forwarded-proto"] || "https") === "https";

  res.setHeader(
    "Set-Cookie",
    serializeCookie(SESSION_COOKIE, "", {
      httpOnly: true,
      secure,
      sameSite: "Lax",
      path: "/",
      maxAge: 0
    })
  );

  res.status(200).json({ ok: true });
};

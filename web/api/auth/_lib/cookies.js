function parseCookies(cookieHeader = "") {
  return cookieHeader
    .split(";")
    .map((item) => item.trim())
    .filter(Boolean)
    .reduce((acc, item) => {
      const idx = item.indexOf("=");
      if (idx === -1) return acc;
      const key = item.slice(0, idx);
      const value = item.slice(idx + 1);
      acc[key] = decodeURIComponent(value);
      return acc;
    }, {});
}

function serializeCookie(name, value, options = {}) {
  const parts = [`${name}=${encodeURIComponent(value)}`];

  if (options.maxAge !== undefined) {
    parts.push(`Max-Age=${Math.floor(options.maxAge)}`);
  }
  if (options.domain) parts.push(`Domain=${options.domain}`);
  if (options.path) parts.push(`Path=${options.path}`);
  if (options.expires) parts.push(`Expires=${options.expires.toUTCString()}`);
  if (options.httpOnly) parts.push("HttpOnly");
  if (options.secure) parts.push("Secure");
  if (options.sameSite) parts.push(`SameSite=${options.sameSite}`);

  return parts.join("; ");
}

function setCookies(res, cookies) {
  const existing = res.getHeader("Set-Cookie");
  const base = Array.isArray(existing) ? existing : existing ? [existing] : [];
  res.setHeader("Set-Cookie", base.concat(cookies));
}

module.exports = {
  parseCookies,
  serializeCookie,
  setCookies
};

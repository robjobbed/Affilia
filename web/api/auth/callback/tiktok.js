const { handleOAuthCallback } = require("../_lib/callbackHandler");

module.exports = async function handler(req, res) {
  return handleOAuthCallback(req, res, "tiktok");
};

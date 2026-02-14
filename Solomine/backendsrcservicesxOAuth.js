const axios = require('axios');

/**
 * Exchange X OAuth authorization code for access token
 */
async function exchangeCodeForToken(code, redirectUri) {
  const clientId = process.env.X_CLIENT_ID;
  const clientSecret = process.env.X_CLIENT_SECRET;
  
  if (!clientId || !clientSecret) {
    throw new Error('X OAuth credentials not configured');
  }
  
  const tokenUrl = 'https://api.twitter.com/2/oauth2/token';
  
  // Create Basic Auth header
  const auth = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  
  const params = new URLSearchParams({
    code: code,
    grant_type: 'authorization_code',
    client_id: clientId,
    redirect_uri: redirectUri,
    code_verifier: 'challenge' // In production, use proper PKCE
  });
  
  try {
    const response = await axios.post(tokenUrl, params.toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': `Basic ${auth}`
      }
    });
    
    return {
      accessToken: response.data.access_token,
      refreshToken: response.data.refresh_token,
      expiresIn: response.data.expires_in,
      tokenType: response.data.token_type
    };
  } catch (error) {
    console.error('X token exchange error:', error.response?.data || error.message);
    throw new Error(`Failed to exchange X authorization code: ${error.response?.data?.error_description || error.message}`);
  }
}

/**
 * Fetch X user profile with access token
 */
async function fetchUserProfile(accessToken) {
  const userUrl = 'https://api.twitter.com/2/users/me';
  
  const params = {
    'user.fields': 'id,name,username,description,profile_image_url,public_metrics,verified,verified_type'
  };
  
  try {
    const response = await axios.get(userUrl, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      },
      params: params
    });
    
    const userData = response.data.data;
    
    return {
      id: userData.id,
      username: userData.username,
      displayName: userData.name,
      bio: userData.description || null,
      profileImageURL: userData.profile_image_url || null,
      followers: userData.public_metrics?.followers_count || 0,
      following: userData.public_metrics?.following_count || 0,
      verified: userData.verified || false,
      email: null // X doesn't provide email in basic scopes
    };
  } catch (error) {
    console.error('X profile fetch error:', error.response?.data || error.message);
    throw new Error(`Failed to fetch X user profile: ${error.response?.data?.error || error.message}`);
  }
}

/**
 * Refresh access token using refresh token
 */
async function refreshAccessToken(refreshToken) {
  const clientId = process.env.X_CLIENT_ID;
  const clientSecret = process.env.X_CLIENT_SECRET;
  
  const tokenUrl = 'https://api.twitter.com/2/oauth2/token';
  const auth = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  
  const params = new URLSearchParams({
    refresh_token: refreshToken,
    grant_type: 'refresh_token',
    client_id: clientId
  });
  
  try {
    const response = await axios.post(tokenUrl, params.toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': `Basic ${auth}`
      }
    });
    
    return {
      accessToken: response.data.access_token,
      refreshToken: response.data.refresh_token,
      expiresIn: response.data.expires_in
    };
  } catch (error) {
    console.error('X token refresh error:', error.response?.data || error.message);
    throw new Error('Failed to refresh X access token');
  }
}

module.exports = {
  exchangeCodeForToken,
  fetchUserProfile,
  refreshAccessToken
};

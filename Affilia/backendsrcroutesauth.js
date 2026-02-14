const express = require('express');
const jwt = require('jsonwebtoken');
const prisma = require('../db/prisma');
const xOAuth = require('../services/xOAuth');
const encryption = require('../services/encryption');
const authenticate = require('../middleware/authenticate');

const router = express.Router();

/**
 * POST /api/auth/x/callback
 * Exchange X OAuth code for access token and create/login user
 */
router.post('/x/callback', async (req, res, next) => {
  try {
    const { code, redirect_uri } = req.body;
    
    if (!code) {
      return res.status(400).json({ 
        error: 'Bad Request',
        message: 'Authorization code is required' 
      });
    }
    
    console.log('📥 Received X OAuth callback');
    console.log('   Code:', code.substring(0, 20) + '...');
    
    // Step 1: Exchange code for access token
    console.log('🔄 Exchanging code for access token...');
    const tokens = await xOAuth.exchangeCodeForToken(code, redirect_uri || 'affilia://auth/x/callback');
    console.log('✅ Access token received');
    
    // Step 2: Fetch user profile from X
    console.log('👤 Fetching X user profile...');
    const xProfile = await xOAuth.fetchUserProfile(tokens.accessToken);
    console.log(`✅ Profile fetched: @${xProfile.username}`);
    
    // Step 3: Find or create user in database
    let user = await prisma.user.findUnique({
      where: { xUserId: xProfile.id }
    });
    
    if (user) {
      // Existing user - update profile data
      console.log(`📝 Updating existing user: ${user.id}`);
      user = await prisma.user.update({
        where: { id: user.id },
        data: {
          xUsername: xProfile.username,
          displayName: xProfile.displayName,
          bio: xProfile.bio,
          profileImageUrl: xProfile.profileImageURL,
          xFollowers: xProfile.followers,
          xFollowing: xProfile.following,
          xVerified: xProfile.verified,
          lastLogin: new Date()
        }
      });
    } else {
      // New user - create record
      console.log('🆕 Creating new user');
      user = await prisma.user.create({
        data: {
          email: xProfile.email || `${xProfile.username}@x.com`,
          xUserId: xProfile.id,
          xUsername: xProfile.username,
          displayName: xProfile.displayName,
          bio: xProfile.bio,
          profileImageUrl: xProfile.profileImageURL,
          xFollowers: xProfile.followers,
          xFollowing: xProfile.following,
          xVerified: xProfile.verified,
          role: null, // User will select role in app
          skills: [],
          projectsCompleted: 0
        }
      });
      console.log(`✅ User created: ${user.id}`);
    }
    
    // Step 4: Store encrypted OAuth tokens
    const expiresAt = new Date(Date.now() + (tokens.expiresIn * 1000));
    
    await prisma.token.create({
      data: {
        userId: user.id,
        xAccessToken: encryption.encrypt(tokens.accessToken),
        xRefreshToken: tokens.refreshToken ? encryption.encrypt(tokens.refreshToken) : null,
        expiresAt: expiresAt
      }
    });
    console.log('🔐 OAuth tokens stored');
    
    // Step 5: Generate JWT for app authentication
    const jwtToken = jwt.sign(
      { 
        userId: user.id,
        xUsername: user.xUsername
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    console.log('🎫 JWT token generated');
    
    // Step 6: Return profile data to iOS app
    const response = {
      token: jwtToken,
      profile: {
        id: user.xUserId,
        username: user.xUsername,
        displayName: user.displayName,
        bio: user.bio,
        profileImageURL: user.profileImageUrl,
        followers: user.xFollowers,
        following: user.xFollowing,
        verified: user.xVerified,
        email: user.email
      }
    };
    
    console.log(`✅ Authentication complete for @${user.xUsername}`);
    console.log('');
    
    res.json(response);
    
  } catch (error) {
    console.error('❌ X OAuth error:', error.message);
    next(error);
  }
});

/**
 * POST /api/auth/x/refresh
 * Refresh X profile data for authenticated user
 */
router.post('/x/refresh', authenticate, async (req, res, next) => {
  try {
    console.log(`🔄 Refreshing X profile for user ${req.userId}`);
    
    // Get stored tokens
    const token = await prisma.token.findFirst({
      where: { userId: req.userId },
      orderBy: { createdAt: 'desc' }
    });
    
    if (!token) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'No X authentication tokens found'
      });
    }
    
    // Decrypt access token
    let accessToken = encryption.decrypt(token.xAccessToken);
    
    // Check if token is expired
    if (new Date() > token.expiresAt && token.xRefreshToken) {
      console.log('🔄 Access token expired, refreshing...');
      const refreshToken = encryption.decrypt(token.xRefreshToken);
      const newTokens = await xOAuth.refreshAccessToken(refreshToken);
      
      // Update stored tokens
      await prisma.token.update({
        where: { id: token.id },
        data: {
          xAccessToken: encryption.encrypt(newTokens.accessToken),
          xRefreshToken: newTokens.refreshToken ? encryption.encrypt(newTokens.refreshToken) : token.xRefreshToken,
          expiresAt: new Date(Date.now() + (newTokens.expiresIn * 1000))
        }
      });
      
      accessToken = newTokens.accessToken;
    }
    
    // Fetch latest profile from X
    const xProfile = await xOAuth.fetchUserProfile(accessToken);
    
    // Update user in database
    const updatedUser = await prisma.user.update({
      where: { id: req.userId },
      data: {
        xUsername: xProfile.username,
        displayName: xProfile.displayName,
        bio: xProfile.bio,
        profileImageUrl: xProfile.profileImageURL,
        xFollowers: xProfile.followers,
        xFollowing: xProfile.following,
        xVerified: xProfile.verified
      }
    });
    
    console.log(`✅ Profile refreshed for @${xProfile.username}`);
    
    res.json({
      profile: {
        id: updatedUser.xUserId,
        username: updatedUser.xUsername,
        displayName: updatedUser.displayName,
        bio: updatedUser.bio,
        profileImageURL: updatedUser.profileImageUrl,
        followers: updatedUser.xFollowers,
        following: updatedUser.xFollowing,
        verified: updatedUser.xVerified,
        email: updatedUser.email
      }
    });
    
  } catch (error) {
    console.error('❌ Refresh error:', error.message);
    next(error);
  }
});

/**
 * POST /api/auth/logout
 * Logout user (delete tokens)
 */
router.post('/logout', authenticate, async (req, res, next) => {
  try {
    // Delete all tokens for this user
    await prisma.token.deleteMany({
      where: { userId: req.userId }
    });
    
    console.log(`👋 User ${req.userId} logged out`);
    
    res.json({ message: 'Logged out successfully' });
    
  } catch (error) {
    next(error);
  }
});

module.exports = router;

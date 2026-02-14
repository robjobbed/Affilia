#!/usr/bin/env node

/**
 * Quick GitHub OAuth Server for Solomine
 * 
 * This is a simple Express server that handles GitHub OAuth.
 * Run this locally for development.
 * 
 * Setup:
 * 1. npm install express axios
 * 2. Replace GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET below
 * 3. node github-oauth-server.js
 * 4. Server runs on http://localhost:3000
 */

const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

// ⚠️ REPLACE THESE WITH YOUR GITHUB OAUTH CREDENTIALS
const GITHUB_CLIENT_ID = 'Ov23liVQKIWJjXw0BKIu';
const GITHUB_CLIENT_SECRET = '1396191734654ebfcd53fcb7f9856e16382d7b0c';

// Health check endpoint
app.get('/', (req, res) => {
    res.json({ 
        status: 'Solomine GitHub OAuth Server',
        version: '1.0.0',
        endpoints: {
            health: 'GET /',
            githubCallback: 'POST /api/auth/github/callback'
        }
    });
});

// GitHub OAuth callback endpoint
app.post('/api/auth/github/callback', async (req, res) => {
    const { code, redirect_uri } = req.body;
    
    console.log('📥 Received GitHub OAuth callback');
    console.log('   Code:', code?.substring(0, 10) + '...');
    console.log('   Redirect URI:', redirect_uri);
    
    if (!code) {
        console.log('❌ No authorization code provided');
        return res.status(400).json({ error: 'Authorization code is required' });
    }
    
    try {
        // Step 1: Exchange authorization code for access token
        console.log('🔄 Exchanging code for access token...');
        const tokenResponse = await axios.post(
            'https://github.com/login/oauth/access_token',
            {
                client_id: GITHUB_CLIENT_ID,
                client_secret: GITHUB_CLIENT_SECRET,
                code: code,
                redirect_uri: redirect_uri
            },
            {
                headers: { 
                    Accept: 'application/json',
                    'Content-Type': 'application/json'
                }
            }
        );
        
        const accessToken = tokenResponse.data.access_token;
        
        if (!accessToken) {
            console.log('❌ Failed to get access token from GitHub');
            console.log('   Response:', tokenResponse.data);
            return res.status(500).json({ error: 'Failed to get access token from GitHub' });
        }
        
        console.log('✅ Got access token:', accessToken.substring(0, 10) + '...');
        
        // Step 2: Fetch user profile from GitHub
        console.log('👤 Fetching GitHub user profile...');
        const userResponse = await axios.get('https://api.github.com/user', {
            headers: {
                Authorization: `Bearer ${accessToken}`,
                Accept: 'application/vnd.github.v3+json'
            }
        });
        
        const user = userResponse.data;
        console.log('✅ Got GitHub user:', user.login);
        console.log('   Name:', user.name);
        console.log('   Public Repos:', user.public_repos);
        console.log('   Followers:', user.followers);
        
        // Step 3: Create session token for your app
        // In production, generate a proper JWT token here
        const appToken = `solomine_github_${user.id}_${Date.now()}`;
        
        // Step 4: Return profile data to iOS app
        const response = {
            token: appToken,
            profile: {
                id: user.id.toString(),
                username: user.login,
                name: user.name,
                bio: user.bio,
                avatarURL: user.avatar_url,
                publicRepos: user.public_repos,
                followers: user.followers,
                following: user.following
            }
        };
        
        console.log('✅ Sending profile to iOS app');
        res.json(response);
        
    } catch (error) {
        console.error('❌ GitHub OAuth error:', error.message);
        
        if (error.response) {
            console.error('   Status:', error.response.status);
            console.error('   Data:', error.response.data);
        }
        
        res.status(500).json({ 
            error: 'GitHub authentication failed',
            details: error.message 
        });
    }
});

// Start server
const PORT = 3000;
app.listen(PORT, () => {
    console.log('');
    console.log('🚀 Solomine GitHub OAuth Server');
    console.log('================================');
    console.log(`✅ Server running on http://localhost:${PORT}`);
    console.log('');
    console.log('📝 Configuration:');
    console.log(`   Client ID: ${GITHUB_CLIENT_ID === 'YOUR_GITHUB_CLIENT_ID' ? '⚠️  NOT SET' : '✅ Set'}`);
    console.log(`   Client Secret: ${GITHUB_CLIENT_SECRET === 'YOUR_GITHUB_CLIENT_SECRET' ? '⚠️  NOT SET' : '✅ Set'}`);
    console.log('');
    console.log('📡 Endpoints:');
    console.log(`   POST http://localhost:${PORT}/api/auth/github/callback`);
    console.log('');
    
    if (GITHUB_CLIENT_ID === 'YOUR_GITHUB_CLIENT_ID' || GITHUB_CLIENT_SECRET === 'YOUR_GITHUB_CLIENT_SECRET') {
        console.log('⚠️  WARNING: Update GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET');
        console.log('   Get them from: https://github.com/settings/developers');
        console.log('');
    }
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('👋 Shutting down server...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('\n👋 Shutting down server...');
    process.exit(0);
});

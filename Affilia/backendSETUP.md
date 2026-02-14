# Affilia Backend Setup Guide

Complete guide to setting up and running the Affilia backend.

## Prerequisites

- Node.js 18+ installed
- PostgreSQL installed and running
- X (Twitter) Developer account with OAuth app created

## Step-by-Step Setup

### 1. Install PostgreSQL

**macOS (Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**Windows:**
Download from https://www.postgresql.org/download/windows/

### 2. Create Database

```bash
# Connect to PostgreSQL
psql postgres

# Create database
CREATE DATABASE affilia;

# Create user (optional)
CREATE USER affilia_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE affilia TO affilia_user;

# Exit
\q
```

### 3. Set Up X (Twitter) OAuth App

1. Go to https://developer.twitter.com/en/portal/dashboard
2. Create a new app or use existing
3. Go to app settings → User authentication settings
4. Enable OAuth 2.0
5. Set redirect URI: `affilia://auth/x/callback`
6. Set scopes: `tweet.read`, `users.read`, `follows.read`
7. Copy your Client ID and Client Secret

### 4. Install Dependencies

```bash
cd backend
npm install
```

### 5. Configure Environment Variables

```bash
# Copy example env file
cp .env.example .env

# Edit .env file
nano .env
```

**Required variables:**
```env
# Server
PORT=3000
NODE_ENV=development

# X OAuth - From X Developer Portal
X_CLIENT_ID=your_actual_client_id_here
X_CLIENT_SECRET=your_actual_client_secret_here

# JWT Secret - Generate random string
JWT_SECRET=run_this_command_to_generate

# Database - Update with your credentials
DATABASE_URL=postgresql://postgres:password@localhost:5432/affilia

# Encryption Key - Generate random string
ENCRYPTION_KEY=run_this_command_to_generate
```

**Generate secrets:**
```bash
# Generate JWT secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Generate encryption key
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 6. Set Up Database Schema

```bash
# Generate Prisma client
npm run generate

# Run database migrations
npm run migrate
```

This will create all tables in your PostgreSQL database.

### 7. Start the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

You should see:
```
🚀 Affilia Backend Server
📡 Server running on port 3000
🌍 Environment: development
✅ Database connected
```

### 8. Test the Backend

**Health check:**
```bash
curl http://localhost:3000/health
```

**Expected response:**
```json
{
  "status": "ok",
  "timestamp": "2026-02-03T...",
  "environment": "development"
}
```

### 9. Update iOS App

In `AuthenticationManager.swift`, update the backend URL:

```swift
// Line ~108
let backendURL = "http://localhost:3000/api/auth/x/callback"

// Or for production:
let backendURL = "https://api.affilia.app/api/auth/x/callback"
```

### 10. Test Full Authentication Flow

1. Run backend: `npm run dev`
2. Run iOS app in simulator
3. Tap "Sign in with X"
4. Authorize the app
5. Check backend logs for:
   ```
   📥 Received X OAuth callback
   🔄 Exchanging code for access token...
   ✅ Access token received
   👤 Fetching X user profile...
   ✅ Profile fetched: @yourusername
   🆕 Creating new user
   ✅ User created: [uuid]
   🔐 OAuth tokens stored
   🎫 JWT token generated
   ✅ Authentication complete for @yourusername
   ```

## Production Deployment

### Deploy to Railway

1. Create account at https://railway.app
2. Create new project
3. Add PostgreSQL database
4. Deploy from GitHub:
   ```bash
   # Install Railway CLI
   npm install -g @railway/cli
   
   # Login
   railway login
   
   # Link project
   railway link
   
   # Deploy
   railway up
   ```

5. Set environment variables in Railway dashboard
6. Copy production URL (e.g., `https://affilia-backend.railway.app`)

### Deploy to Heroku

```bash
# Install Heroku CLI
brew install heroku/brew/heroku

# Login
heroku login

# Create app
heroku create affilia-backend

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set X_CLIENT_ID=your_id
heroku config:set X_CLIENT_SECRET=your_secret
heroku config:set JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
heroku config:set ENCRYPTION_KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")

# Deploy
git push heroku main

# Check logs
heroku logs --tail
```

### Deploy to DigitalOcean

1. Create a Droplet (Ubuntu 22.04)
2. SSH into server
3. Install Node.js and PostgreSQL
4. Clone your repository
5. Install dependencies
6. Set up environment variables
7. Use PM2 to run the server:
   ```bash
   npm install -g pm2
   pm2 start src/server.js --name affilia-backend
   pm2 startup
   pm2 save
   ```

## Database Management

**View data in Prisma Studio:**
```bash
npm run studio
```

This opens a GUI at http://localhost:5555 to browse your database.

**Run migrations:**
```bash
npm run migrate
```

**Reset database (DEV ONLY):**
```bash
npx prisma migrate reset
```

## API Testing

### Test Authentication Endpoint

```bash
# Test X OAuth callback (will fail without valid code)
curl -X POST http://localhost:3000/api/auth/x/callback \
  -H "Content-Type: application/json" \
  -d '{
    "code": "TEST_CODE",
    "redirect_uri": "affilia://auth/x/callback"
  }'
```

### Test with Real OAuth Flow

1. Sign in through iOS app
2. Check backend logs for the JWT token
3. Use that token for subsequent requests:

```bash
# Get current user
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"

# Update user role
curl -X PUT http://localhost:3000/api/users/me/role \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"role": "I BUILD"}'

# Update profile
curl -X PUT http://localhost:3000/api/users/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Full-stack developer",
    "skills": ["SwiftUI", "Node.js", "PostgreSQL"],
    "hourlyRate": 150,
    "availability": "OPEN_TO_WORK"
  }'
```

## Troubleshooting

### Database Connection Error
```
Error: Can't reach database server
```
**Fix:** Make sure PostgreSQL is running:
```bash
brew services start postgresql@15
# or
sudo systemctl start postgresql
```

### X OAuth Error
```
Failed to exchange X authorization code
```
**Fix:** Check X_CLIENT_ID and X_CLIENT_SECRET in .env

### Port Already in Use
```
Error: listen EADDRINUSE: address already in use :::3000
```
**Fix:** Kill the process using port 3000:
```bash
lsof -ti:3000 | xargs kill
```

### Prisma Error
```
Prisma Client not generated
```
**Fix:**
```bash
npm run generate
```

## Monitoring

**Check server status:**
```bash
curl http://localhost:3000/health
```

**View logs:**
```bash
# Development
# Logs appear in terminal

# Production (with PM2)
pm2 logs affilia-backend
```

## Security Checklist

- [ ] X_CLIENT_SECRET is in .env (never committed to git)
- [ ] JWT_SECRET is randomly generated
- [ ] ENCRYPTION_KEY is randomly generated
- [ ] Database password is strong
- [ ] HTTPS is enabled in production
- [ ] CORS is configured correctly
- [ ] Rate limiting is enabled
- [ ] Environment is set to "production"

---

Your backend is now ready! 🚀

The iOS app can now authenticate users with real X accounts.

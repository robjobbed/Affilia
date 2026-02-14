# Production Deployment Guide

Quick deployment guides for popular platforms.

## Railway (Recommended - Easiest)

Railway automatically provisions PostgreSQL and handles deployments.

### Setup (5 minutes)

```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login to Railway
railway login

# 3. Initialize project
cd backend
railway init

# 4. Add PostgreSQL
railway add postgresql

# 5. Set environment variables
railway variables set X_CLIENT_ID=your_x_client_id
railway variables set X_CLIENT_SECRET=your_x_client_secret
railway variables set JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
railway variables set ENCRYPTION_KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
railway variables set NODE_ENV=production

# 6. Deploy
railway up

# 7. Run migrations
railway run npm run migrate:deploy

# 8. Get your production URL
railway domain
```

**Your backend is live!** Update iOS app with the URL:
```swift
let backendURL = "https://your-app.railway.app/api/auth/x/callback"
```

### Railway Dashboard
- View logs: https://railway.app/dashboard
- Manage environment variables
- View metrics
- Auto-redeploy on git push

---

## Render

Free tier available with automatic deploys from GitHub.

### Setup

1. **Create account:** https://render.com
2. **New Web Service**
3. **Connect GitHub repository**
4. **Configure:**
   - Name: `affilia-backend`
   - Environment: `Node`
   - Build Command: `npm install && npm run generate`
   - Start Command: `npm start`
   - Instance Type: `Free`

5. **Add PostgreSQL:**
   - New → PostgreSQL
   - Name: `affilia-db`
   - Copy internal database URL

6. **Environment Variables:**
   ```
   DATABASE_URL=<from-postgresql-service>
   X_CLIENT_ID=your_client_id
   X_CLIENT_SECRET=your_client_secret
   JWT_SECRET=<generate-random>
   ENCRYPTION_KEY=<generate-random>
   NODE_ENV=production
   ```

7. **Deploy** - Render auto-deploys on git push

8. **Run Migrations:**
   - Go to Render dashboard
   - Select your service
   - Shell → Run: `npm run migrate:deploy`

**URL:** `https://affilia-backend.onrender.com`

---

## Fly.io

Great for global deployment with edge locations.

### Setup

```bash
# 1. Install Fly CLI
curl -L https://fly.io/install.sh | sh

# 2. Login
fly auth login

# 3. Launch app
cd backend
fly launch

# Answer prompts:
# App name: affilia-backend
# Region: Choose closest to you
# PostgreSQL: Yes
# Redis: No

# 4. Set environment variables
fly secrets set X_CLIENT_ID=your_client_id
fly secrets set X_CLIENT_SECRET=your_client_secret
fly secrets set JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
fly secrets set ENCRYPTION_KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")

# 5. Deploy
fly deploy

# 6. Run migrations
fly ssh console
npm run migrate:deploy
exit

# 7. Get URL
fly info
```

**URL:** `https://affilia-backend.fly.dev`

---

## Heroku

Classic PaaS platform, easy to use.

### Setup

```bash
# 1. Install Heroku CLI
brew install heroku/brew/heroku

# 2. Login
heroku login

# 3. Create app
cd backend
heroku create affilia-backend

# 4. Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# 5. Set environment variables
heroku config:set X_CLIENT_ID=your_client_id
heroku config:set X_CLIENT_SECRET=your_client_secret
heroku config:set JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
heroku config:set ENCRYPTION_KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
heroku config:set NODE_ENV=production

# 6. Deploy
git push heroku main

# 7. Run migrations
heroku run npm run migrate:deploy

# 8. Check logs
heroku logs --tail

# 9. Open app
heroku open
```

**URL:** `https://affilia-backend.herokuapp.com`

---

## DigitalOcean App Platform

Similar to Heroku with better pricing.

### Setup

1. **Create account:** https://cloud.digitalocean.com
2. **Create App**
3. **Connect GitHub repository**
4. **Configure:**
   - Name: `affilia-backend`
   - Branch: `main`
   - Autodeploy: Enabled
   - Build Command: `npm install && npm run generate`
   - Run Command: `npm start`

5. **Add Database:**
   - Create → Database → PostgreSQL
   - Copy connection string

6. **Environment Variables:**
   ```
   DATABASE_URL=${db.DATABASE_URL}
   X_CLIENT_ID=your_client_id
   X_CLIENT_SECRET=your_client_secret
   JWT_SECRET=<generate>
   ENCRYPTION_KEY=<generate>
   NODE_ENV=production
   ```

7. **Deploy**

8. **Run Migrations:**
   - Console → Run: `npm run migrate:deploy`

**URL:** `https://affilia-backend-xxxxx.ondigitalocean.app`

---

## Vercel (Serverless)

Great for serverless deployments.

### Setup

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Login
vercel login

# 3. Deploy
cd backend
vercel

# Answer prompts, then:

# 4. Add environment variables in Vercel dashboard
# https://vercel.com/your-username/affilia-backend/settings/environment-variables

# 5. Redeploy
vercel --prod
```

**Note:** You'll need to provision PostgreSQL separately (Supabase, Neon, etc.)

---

## AWS Elastic Beanstalk

Full-featured AWS deployment.

### Setup

```bash
# 1. Install EB CLI
pip install awsebcli

# 2. Initialize
cd backend
eb init

# Select:
# Region: us-east-1 (or preferred)
# Platform: Node.js
# App name: affilia-backend

# 3. Create environment
eb create affilia-backend-prod

# 4. Set environment variables
eb setenv X_CLIENT_ID=your_client_id \
  X_CLIENT_SECRET=your_client_secret \
  JWT_SECRET=<generate> \
  ENCRYPTION_KEY=<generate> \
  NODE_ENV=production

# 5. Deploy
eb deploy

# 6. Open app
eb open
```

**Note:** Add RDS PostgreSQL from AWS Console.

---

## Self-Hosted VPS (DigitalOcean/Linode/Vultr)

For full control.

### Setup

```bash
# 1. Create Droplet (Ubuntu 22.04)
# 2. SSH into server
ssh root@your-server-ip

# 3. Install dependencies
apt update
apt install -y nodejs npm postgresql nginx

# 4. Create database
sudo -u postgres createdb affilia
sudo -u postgres createuser affilia_user
sudo -u postgres psql -c "ALTER USER affilia_user WITH PASSWORD 'secure_password';"

# 5. Clone repository
git clone https://github.com/yourusername/affilia-backend.git
cd affilia-backend/backend

# 6. Install dependencies
npm install

# 7. Set environment variables
nano .env
# Add all variables

# 8. Run migrations
npm run migrate:deploy

# 9. Install PM2
npm install -g pm2

# 10. Start server
pm2 start src/server.js --name affilia-backend
pm2 startup
pm2 save

# 11. Configure Nginx
nano /etc/nginx/sites-available/affilia
```

**Nginx config:**
```nginx
server {
    listen 80;
    server_name api.affilia.app;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
ln -s /etc/nginx/sites-available/affilia /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# Set up SSL
apt install certbot python3-certbot-nginx
certbot --nginx -d api.affilia.app
```

---

## Comparison

| Platform | Free Tier | Database | Ease | Speed |
|----------|-----------|----------|------|-------|
| Railway | ✅ $5 credit | ✅ Included | ⭐⭐⭐⭐⭐ | ⚡⚡⚡ |
| Render | ✅ Yes | ✅ Included | ⭐⭐⭐⭐⭐ | ⚡⚡ |
| Fly.io | ✅ Limited | ✅ Included | ⭐⭐⭐⭐ | ⚡⚡⚡ |
| Heroku | ❌ Paid only | ✅ Add-on | ⭐⭐⭐⭐⭐ | ⚡⚡⚡ |
| DigitalOcean | ❌ Paid | ✅ Separate | ⭐⭐⭐⭐ | ⚡⚡⚡ |
| Vercel | ✅ Yes | ❌ Separate | ⭐⭐⭐ | ⚡⚡⚡⚡ |
| AWS EB | ✅ 1 year | ❌ Separate | ⭐⭐ | ⚡⚡⚡ |
| VPS | ❌ Paid | ✅ Self-hosted | ⭐ | ⚡⚡⚡⚡⚡ |

**Recommendation:** Start with **Railway** or **Render** for simplicity.

---

## After Deployment

### 1. Update iOS App
```swift
// In AuthenticationManager.swift
let backendURL = "https://your-production-url.com/api/auth/x/callback"
```

### 2. Test Production
```bash
# Health check
curl https://your-production-url.com/health

# Sign in through iOS app
# Watch production logs
```

### 3. Update X OAuth App
In X Developer Portal, add production redirect URI:
```
https://your-production-url.com/auth/x/callback
```

### 4. Monitor
- Set up error tracking (Sentry)
- Monitor uptime (UptimeRobot)
- Check logs regularly

### 5. Set Up CI/CD
Most platforms auto-deploy on git push to main branch.

---

## Quick Deploy Commands

```bash
# Railway
railway up

# Render
git push origin main  # Auto-deploys

# Fly.io
fly deploy

# Heroku
git push heroku main

# Vercel
vercel --prod
```

---

## Troubleshooting Deployments

### "Cannot connect to database"
- Check DATABASE_URL environment variable
- Ensure database is in same region
- Verify database credentials

### "X OAuth fails in production"
- Add production URL to X Developer Portal redirect URIs
- Verify X_CLIENT_ID and X_CLIENT_SECRET

### "502 Bad Gateway"
- Check server is running
- Check PORT environment variable
- Review platform logs

### "Rate limit errors"
- Increase rate limit in production
- Configure ALLOWED_ORIGINS properly

---

Your backend is production-ready! 🚀

Choose a platform, deploy in 5 minutes, and your app will use real X authentication.

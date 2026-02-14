# Affilia Backend - Quick Reference

## One-Command Setup

```bash
cd backend && chmod +x setup.sh && ./setup.sh
```

## Common Commands

```bash
# Development
npm run dev              # Start server with auto-reload
npm run studio           # Open database GUI

# Database
npm run migrate          # Run migrations
npm run generate         # Generate Prisma client

# Production
npm start                # Start production server
```

## API Endpoints

### Authentication
| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/api/auth/x/callback` | No | Exchange X OAuth code for token |
| POST | `/api/auth/x/refresh` | Yes | Refresh X profile data |
| POST | `/api/auth/logout` | Yes | Logout user |

### Users
| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/api/users/me` | Yes | Get current user |
| PUT | `/api/users/me` | Yes | Update profile |
| PUT | `/api/users/me/role` | Yes | Set role (builder/hirer) |
| GET | `/api/users/:username` | Yes | Get user by X username |

### Health
| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/health` | No | Server health check |

## Request Examples

### Sign In with X
```bash
POST /api/auth/x/callback
Content-Type: application/json

{
  "code": "AUTHORIZATION_CODE_FROM_X",
  "redirect_uri": "affilia://auth/x/callback"
}
```

### Set User Role
```bash
PUT /api/users/me/role
Authorization: Bearer JWT_TOKEN
Content-Type: application/json

{
  "role": "I BUILD"
}
```

### Update Profile
```bash
PUT /api/users/me
Authorization: Bearer JWT_TOKEN
Content-Type: application/json

{
  "bio": "iOS Developer",
  "skills": ["SwiftUI", "UIKit"],
  "hourlyRate": 150,
  "availability": "OPEN_TO_WORK"
}
```

## Environment Variables

```env
# Required
X_CLIENT_ID=xxx
X_CLIENT_SECRET=xxx
JWT_SECRET=xxx
DATABASE_URL=postgresql://user:pass@localhost:5432/affilia
ENCRYPTION_KEY=xxx

# Optional
PORT=3000
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:3000
```

## Database Schema

### User Table
```sql
id              UUID PRIMARY KEY
email           VARCHAR UNIQUE
role            VARCHAR (NULL, "I BUILD", "I HIRE")
xUserId         VARCHAR UNIQUE
xUsername       VARCHAR UNIQUE
displayName     VARCHAR
bio             TEXT
profileImageUrl VARCHAR
xFollowers      INT
xFollowing      INT
xVerified       BOOLEAN
skills          VARCHAR[]
hourlyRate      INT
availability    VARCHAR
portfolioProjects JSON
projectsCompleted INT
averageRating   FLOAT
createdAt       TIMESTAMP
updatedAt       TIMESTAMP
lastLogin       TIMESTAMP
```

### Token Table
```sql
id              UUID PRIMARY KEY
userId          UUID (FK to User)
xAccessToken    VARCHAR (encrypted)
xRefreshToken   VARCHAR (encrypted)
expiresAt       TIMESTAMP
createdAt       TIMESTAMP
updatedAt       TIMESTAMP
```

## Ports

- **3000** - Backend API server
- **5432** - PostgreSQL database
- **5555** - Prisma Studio (when running)

## File Structure

```
backend/
├── src/
│   ├── server.js                 # Main entry point
│   ├── routes/
│   │   ├── auth.js               # Authentication routes
│   │   └── users.js              # User routes
│   ├── middleware/
│   │   ├── authenticate.js       # JWT authentication
│   │   └── errorHandler.js       # Error handling
│   ├── services/
│   │   ├── xOAuth.js             # X OAuth service
│   │   └── encryption.js         # Token encryption
│   └── db/
│       └── prisma.js             # Database client
├── prisma/
│   └── schema.prisma             # Database schema
├── package.json
├── .env                          # Environment variables
├── .env.example                  # Example env file
└── README.md
```

## Deployment Checklist

- [ ] PostgreSQL database provisioned
- [ ] Environment variables set
- [ ] X OAuth app configured
- [ ] Database migrations run
- [ ] HTTPS enabled
- [ ] CORS configured for production domain
- [ ] Logs set up
- [ ] Health monitoring enabled

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't connect to database | Check PostgreSQL is running: `brew services start postgresql@15` |
| X OAuth fails | Verify X_CLIENT_ID and X_CLIENT_SECRET in .env |
| Port 3000 in use | Kill process: `lsof -ti:3000 \| xargs kill` |
| Prisma errors | Run: `npm run generate && npm run migrate` |
| iOS can't reach backend | Check backend URL in AuthenticationManager.swift |

## Support

- Check logs in terminal
- Use Prisma Studio to inspect database: `npm run studio`
- View full setup guide: `SETUP.md`
- View testing guide: `TESTING.md`

---

**Quick Start:** `cd backend && npm run dev` 🚀

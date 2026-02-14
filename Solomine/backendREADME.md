# Solomine Backend

Node.js/Express backend for Solomine app - handles X (Twitter) OAuth and user management.

## Quick Start

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your credentials

# Run development server
npm run dev

# Run production server
npm start
```

## Environment Variables

Create a `.env` file:

```env
# Server
PORT=3000
NODE_ENV=development

# X (Twitter) OAuth
X_CLIENT_ID=your_x_client_id_here
X_CLIENT_SECRET=your_x_client_secret_here

# JWT Secret (generate with: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
JWT_SECRET=your_jwt_secret_here

# Database (PostgreSQL)
DATABASE_URL=postgresql://user:password@localhost:5432/solomine

# Encryption Key (for storing OAuth tokens)
ENCRYPTION_KEY=your_encryption_key_here
```

## API Endpoints

### Authentication
- `POST /api/auth/x/callback` - Exchange X OAuth code for user profile
- `POST /api/auth/x/refresh` - Refresh X profile data
- `POST /api/auth/logout` - Logout user

### User
- `GET /api/users/me` - Get current user profile
- `PUT /api/users/me` - Update user profile
- `PUT /api/users/me/role` - Set user role (builder/hirer)

## Tech Stack

- Node.js + Express
- PostgreSQL (database)
- Prisma (ORM)
- JWT (authentication)
- Axios (HTTP client)

## Project Structure

```
backend/
├── src/
│   ├── routes/
│   │   ├── auth.js
│   │   └── users.js
│   ├── middleware/
│   │   ├── authenticate.js
│   │   └── errorHandler.js
│   ├── services/
│   │   ├── xOAuth.js
│   │   └── encryption.js
│   ├── db/
│   │   └── prisma.js
│   └── server.js
├── prisma/
│   └── schema.prisma
├── package.json
└── .env
```

#!/bin/bash

echo "🚀 Solomine Backend Quick Start"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    echo "   Install from: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js $(node -v) detected"

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL is not installed"
    echo "   Install: brew install postgresql@15"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ PostgreSQL detected"
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo ""
    echo "📝 Creating .env file..."
    cp .env.example .env
    
    # Generate JWT secret
    JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    ENCRYPTION_KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    
    # Update .env with generated secrets
    sed -i '' "s/generate_a_random_secret_here/$JWT_SECRET/" .env
    sed -i '' "s/generate_a_random_encryption_key_here/$ENCRYPTION_KEY/" .env
    
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env and add your X OAuth credentials:"
    echo "   X_CLIENT_ID=..."
    echo "   X_CLIENT_SECRET=..."
    echo ""
    read -p "Press enter when ready to continue..."
fi

# Install dependencies
if [ ! -d "node_modules" ]; then
    echo ""
    echo "📦 Installing dependencies..."
    npm install
    echo "✅ Dependencies installed"
fi

# Generate Prisma client
echo ""
echo "🔨 Generating Prisma client..."
npm run generate

# Run migrations
echo ""
echo "🗄️  Setting up database..."
echo "   Make sure PostgreSQL is running!"
read -p "Press enter to run migrations..."
npm run migrate

echo ""
echo "✅ Setup complete!"
echo ""
echo "Start the server with:"
echo "  npm run dev"
echo ""

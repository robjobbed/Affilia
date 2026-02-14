const jwt = require('jsonwebtoken');
const prisma = require('../db/prisma');

/**
 * Authenticate user from JWT token
 */
async function authenticate(req, res, next) {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        error: 'Unauthorized',
        message: 'No authentication token provided' 
      });
    }
    
    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    // Verify JWT
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      return res.status(401).json({ 
        error: 'Unauthorized',
        message: 'Invalid or expired token' 
      });
    }
    
    // Fetch user from database
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        role: true,
        xUserId: true,
        xUsername: true,
        displayName: true,
        bio: true,
        profileImageUrl: true,
        xFollowers: true,
        xFollowing: true,
        xVerified: true,
        skills: true,
        hourlyRate: true,
        availability: true,
        portfolioProjects: true,
        projectsCompleted: true,
        averageRating: true,
        createdAt: true,
        lastLogin: true
      }
    });
    
    if (!user) {
      return res.status(401).json({ 
        error: 'Unauthorized',
        message: 'User not found' 
      });
    }
    
    // Attach user to request
    req.user = user;
    req.userId = user.id;
    
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(500).json({ 
      error: 'Internal Server Error',
      message: 'Authentication failed' 
    });
  }
}

module.exports = authenticate;

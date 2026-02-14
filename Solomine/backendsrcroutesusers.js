const express = require('express');
const prisma = require('../db/prisma');
const authenticate = require('../middleware/authenticate');

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * GET /api/users/me
 * Get current user profile
 */
router.get('/me', async (req, res, next) => {
  try {
    res.json({
      user: {
        id: req.user.id,
        email: req.user.email,
        role: req.user.role,
        xUsername: req.user.xUsername,
        displayName: req.user.displayName,
        bio: req.user.bio,
        profileImageUrl: req.user.profileImageUrl,
        xFollowers: req.user.xFollowers,
        xFollowing: req.user.xFollowing,
        xVerified: req.user.xVerified,
        skills: req.user.skills,
        hourlyRate: req.user.hourlyRate,
        availability: req.user.availability,
        portfolioProjects: req.user.portfolioProjects,
        projectsCompleted: req.user.projectsCompleted,
        averageRating: req.user.averageRating,
        memberSince: req.user.createdAt
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /api/users/me
 * Update user profile
 */
router.put('/me', async (req, res, next) => {
  try {
    const { 
      bio, 
      skills, 
      hourlyRate, 
      availability, 
      portfolioProjects 
    } = req.body;
    
    // Build update object (only include provided fields)
    const updateData = {};
    if (bio !== undefined) updateData.bio = bio;
    if (skills !== undefined) updateData.skills = skills;
    if (hourlyRate !== undefined) updateData.hourlyRate = hourlyRate;
    if (availability !== undefined) updateData.availability = availability;
    if (portfolioProjects !== undefined) updateData.portfolioProjects = portfolioProjects;
    
    const updatedUser = await prisma.user.update({
      where: { id: req.userId },
      data: updateData
    });
    
    console.log(`📝 User ${req.userId} updated profile`);
    
    res.json({
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        role: updatedUser.role,
        xUsername: updatedUser.xUsername,
        displayName: updatedUser.displayName,
        bio: updatedUser.bio,
        profileImageUrl: updatedUser.profileImageUrl,
        xFollowers: updatedUser.xFollowers,
        xFollowing: updatedUser.xFollowing,
        xVerified: updatedUser.xVerified,
        skills: updatedUser.skills,
        hourlyRate: updatedUser.hourlyRate,
        availability: updatedUser.availability,
        portfolioProjects: updatedUser.portfolioProjects,
        projectsCompleted: updatedUser.projectsCompleted,
        averageRating: updatedUser.averageRating
      }
    });
    
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /api/users/me/role
 * Set user role (affiliate or company)
 */
router.put('/me/role', async (req, res, next) => {
  try {
    const { role } = req.body;
    
    const normalizedRole = {
      'I BUILD': 'AFFILIATE',
      'AFFILIATE': 'AFFILIATE',
      'I HIRE': 'COMPANY',
      'COMPANY': 'COMPANY'
    }[String(role || '').toUpperCase()];
    
    if (!normalizedRole) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Role must be "AFFILIATE" or "COMPANY"'
      });
    }
    
    const updatedUser = await prisma.user.update({
      where: { id: req.userId },
      data: { role: normalizedRole }
    });
    
    console.log(`🎯 User ${req.userId} set role to: ${normalizedRole}`);
    
    res.json({
      user: {
        id: updatedUser.id,
        role: updatedUser.role
      }
    });
    
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/users/:username
 * Get public profile by X username
 */
router.get('/:username', async (req, res, next) => {
  try {
    const { username } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { xUsername: username },
      select: {
        id: true,
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
        role: true
      }
    });
    
    if (!user) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'User not found'
      });
    }
    
    res.json({ user });
    
  } catch (error) {
    next(error);
  }
});

module.exports = router;

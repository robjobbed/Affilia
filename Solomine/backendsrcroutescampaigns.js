const express = require('express');
const authenticate = require('../middleware/authenticate');

const router = express.Router();

const campaignContracts = [
  {
    id: 'demo-neoncart-us-dtc',
    companyName: 'NeonCart',
    companyHandle: '@neoncart',
    title: 'US DTC Skincare - Creator Contract',
    description: 'Recruiting creator and content affiliates for first-purchase CPA campaigns.',
    category: 'INFLUENCERS',
    priority: 'HOT',
    monthlyPayoutCap: 6500,
    commissionType: 'CPA',
    commissionValue: 58,
    cookieWindowDays: 45,
    targetRegion: 'US / Canada',
    terms: ['No trademark bidding', 'Sponsored disclosure required', 'No incent traffic'],
    createdAt: new Date().toISOString(),
    applications: []
  }
];

/**
 * GET /api/campaign-contracts
 * Public feed of campaign contracts
 */
router.get('/', (req, res) => {
  res.json({
    contracts: campaignContracts.map(({ applications, ...contract }) => ({
      ...contract,
      applicationCount: applications.length
    }))
  });
});

/**
 * GET /api/campaign-contracts/:id
 * Contract detail
 */
router.get('/:id', (req, res) => {
  const contract = campaignContracts.find((item) => item.id === req.params.id);

  if (!contract) {
    return res.status(404).json({
      error: 'Not Found',
      message: 'Campaign contract not found'
    });
  }

  return res.json({ contract });
});

/**
 * POST /api/campaign-contracts
 * Create campaign contract (company role)
 */
router.post('/', authenticate, (req, res) => {
  const {
    title,
    description,
    category,
    priority,
    monthlyPayoutCap,
    commissionType,
    commissionValue,
    cookieWindowDays,
    targetRegion,
    terms
  } = req.body;

  if (!title || !description || !monthlyPayoutCap || !commissionType || !commissionValue) {
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Missing required campaign contract fields'
    });
  }

  const contract = {
    id: `contract-${Date.now()}`,
    companyName: req.user.displayName || 'Company',
    companyHandle: `@${req.user.xUsername}`,
    title,
    description,
    category: category || 'OTHER',
    priority: priority || 'STANDARD',
    monthlyPayoutCap: Number(monthlyPayoutCap),
    commissionType,
    commissionValue: Number(commissionValue),
    cookieWindowDays: Number(cookieWindowDays || 30),
    targetRegion: targetRegion || 'Global',
    terms: Array.isArray(terms) ? terms : [],
    createdAt: new Date().toISOString(),
    applications: []
  };

  campaignContracts.unshift(contract);

  return res.status(201).json({ contract });
});

/**
 * POST /api/campaign-contracts/:id/apply
 * Affiliate application to a campaign contract
 */
router.post('/:id/apply', authenticate, (req, res) => {
  const { channelSummary, audienceSize, notes } = req.body;
  const contract = campaignContracts.find((item) => item.id === req.params.id);

  if (!contract) {
    return res.status(404).json({
      error: 'Not Found',
      message: 'Campaign contract not found'
    });
  }

  const existingApplication = contract.applications.find((item) => item.userId === req.userId);
  if (existingApplication) {
    return res.status(409).json({
      error: 'Conflict',
      message: 'You already applied to this contract'
    });
  }

  const application = {
    id: `application-${Date.now()}`,
    userId: req.userId,
    applicantHandle: `@${req.user.xUsername}`,
    channelSummary: channelSummary || 'Not provided',
    audienceSize: audienceSize || 'Not provided',
    notes: notes || '',
    status: 'PENDING',
    appliedAt: new Date().toISOString()
  };

  contract.applications.push(application);

  return res.status(201).json({ application });
});

/**
 * GET /api/campaign-contracts/:id/applications
 * Company view of applications
 */
router.get('/:id/applications', authenticate, (req, res) => {
  const contract = campaignContracts.find((item) => item.id === req.params.id);

  if (!contract) {
    return res.status(404).json({
      error: 'Not Found',
      message: 'Campaign contract not found'
    });
  }

  return res.json({ applications: contract.applications });
});

module.exports = router;


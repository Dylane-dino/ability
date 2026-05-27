// routes/applicationRoutes.js
const express = require('express');
const router = express.Router();
const applicationController = require('../controllers/applicationController');

// POST /api/applications - Submit job application
router.post('/', applicationController.createApplication);

// GET /api/applications/job/:jobId - Get all applications for a job (employer)
router.get('/job/:jobId', applicationController.getJobApplications);

// GET /api/applications/seeker/:seekerId - Get all applications by a seeker
router.get('/seeker/:seekerId', applicationController.getSeekerApplications);

// PUT /api/applications/:applicationId/status - Update application status
router.put('/:applicationId/status', applicationController.updateApplicationStatus);

module.exports = router;

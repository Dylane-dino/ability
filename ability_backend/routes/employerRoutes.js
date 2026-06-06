// routes/employerRoutes.js
const express = require('express');
const router = express.Router();
const employerController = require('../controllers/employerController');

// Route for dashboard card stats counters
router.get('/dashboard/:employerId', employerController.getEmployerDashboardStats);

// Route to populate "Your Active Listings" widget list
router.get('/jobs/:employerId', employerController.getEmployerActiveJobs);

module.exports = router;
// routes/jobRoutes.js
const express = require('express');
const router = express.Router();
const jobController = require('../controllers/jobController');

// POST /api/jobs -> Trigger the createJob function
router.post('/', jobController.createJob);

// GET /api/jobs -> Trigger the getJobs function
router.get('/', jobController.getJobs);
// Add this alongside your other job router mappings
router.get('/employer-dashboard', jobController.getEmployerDashboard);

module.exports = router;
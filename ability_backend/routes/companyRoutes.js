// routes/companyRoutes.js
const express = require('express');
const router = express.Router();
const companyController = require('../controllers/companyController');

// GET /api/companies/:companyId/admin
router.get('/:companyId/admin', companyController.getCompanyAdmin);

module.exports = router;

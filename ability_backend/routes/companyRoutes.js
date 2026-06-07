// routes/companyRoutes.js
const express = require('express');
const router = express.Router();
const companyController = require('../controllers/companyController');

// POST /api/companies -> Create a new company
router.post('/', companyController.createCompany);

// GET /api/companies/:companyId/admin
router.get('/:companyId/admin', companyController.getCompanyAdmin);

module.exports = router;
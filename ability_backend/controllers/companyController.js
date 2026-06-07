// controllers/companyController.js
const pool = require('../config/db');
const jwt = require('jsonwebtoken');
require('dotenv').config();

// --- GET COMPANY ADMIN USER ID ---
exports.getCompanyAdmin = async(req, res) => {
    const { companyId } = req.params;

    try {
        const { rows } = await pool.query(
            'SELECT admin_user_id, company_name FROM companies WHERE company_id = $1', [companyId]
        );

        if (rows.length === 0) {
            return res.status(404).json({ message: 'Company not found.' });
        }

        res.status(200).json(rows[0]);
    } catch (error) {
        console.error('Error fetching company admin:', error);
        res.status(500).json({ message: 'Server error.' });
    }
};

// --- CREATE COMPANY ---
exports.createCompany = async(req, res) => {
    try {
        const { name, address, admin_user_id } = req.body;

        // Determine admin user id: prefer explicit body value, otherwise use JWT
        let adminUserId = admin_user_id || null;

        if (!adminUserId) {
            const authHeader = req.headers.authorization || '';
            if (authHeader.startsWith('Bearer ')) {
                const token = authHeader.split(' ')[1];
                try {
                    const decoded = jwt.verify(token, process.env.JWT_SECRET);
                    adminUserId = decoded.userId || decoded.userId || decoded.user_id || null;
                } catch (e) {
                    // ignore token errors; adminUserId may still be provided in body
                    console.error('JWT verify failed when creating company:', e.message);
                }
            }
        }

        if (!adminUserId) {
            return res.status(400).json({ message: 'admin_user_id required (either in body or via auth token).' });
        }

        const companyName = name || `Company ${adminUserId}`;

        const { rows: insertedCompanies } = await pool.query(
            'INSERT INTO companies (admin_user_id, company_name, created_at) VALUES ($1, $2, NOW()) RETURNING company_id', [adminUserId, companyName]
        );

        const insertedId = insertedCompanies[0].company_id;

        const { rows } = await pool.query('SELECT company_id, company_name, admin_user_id FROM companies WHERE company_id = $1', [insertedId]);

        res.status(201).json(rows[0]);
    } catch (error) {
        console.error('Error creating company:', error);
        res.status(500).json({ message: 'Server error creating company.' });
    }
};

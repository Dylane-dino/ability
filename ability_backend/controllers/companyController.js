// controllers/companyController.js
const pool = require('../config/db');

// --- GET COMPANY ADMIN USER ID ---
exports.getCompanyAdmin = async (req, res) => {
  const { companyId } = req.params;

  try {
    const [rows] = await pool.query(
      'SELECT admin_user_id, company_name FROM companies WHERE company_id = ?',
      [companyId]
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

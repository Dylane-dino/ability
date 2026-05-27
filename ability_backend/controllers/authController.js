const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// --- REGISTER A NEW USER ---
exports.register = async(req, res) => {
    // 🚀 Added companyName to the incoming request body
    const { email, password, role, companyName } = req.body;

    try {
        // 1. Check if user already exists
        const [existingUsers] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'User already exists with this email.' });
        }

        // 2. Hash the password for security
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(password, salt);

        // 3. Insert the new user into the database
        const [result] = await pool.query(
            'INSERT INTO users (email, password_hash, role) VALUES (?, ?, ?)', [email, passwordHash, role]
        );

        const newUserId = result.insertId;

        // 4. 🚀 OOP Logic: Automatically create the company if the user is an employer
        if (role === 'employer' && companyName) {
            // We insert the new user's ID, the company name, and some default values for the required columns
            await pool.query(
                'INSERT INTO companies (admin_user_id, company_name, reality_score, inclusivity_tier) VALUES (?, ?, ?, ?)', [newUserId, companyName, 1.00, 'None']
            );

            return res.status(201).json({
                message: 'Employer and Company registered successfully!',
                userId: newUserId
            });
        }

        // If it is a seeker, just return the standard success message
        res.status(201).json({
            message: 'User registered successfully!',
            userId: newUserId
        });

    } catch (error) {
        console.error('Registration Error:', error);
        res.status(500).json({ message: 'Server error during registration.' });
    }
};

// --- LOGIN AN EXISTING USER ---
// --- LOGIN AN EXISTING USER ---
exports.login = async(req, res) => {
    const { email, password } = req.body;

    try {
        // 1. Find the user by email
        const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found.' });
        }

        const user = users[0];

        // 2. Compare the provided password with the hashed password in DB
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials.' });
        }

        // 3. 🚀 NEW: If they are an employer, find their company_id!
        let companyId = null;
        if (user.role === 'employer') {
            const [companies] = await pool.query('SELECT company_id FROM companies WHERE admin_user_id = ?', [user.user_id]);
            if (companies.length > 0) {
                companyId = companies[0].company_id;
            }
        }

        // 4. Generate a JWT Token
        const token = jwt.sign({ userId: user.user_id, role: user.role },
            process.env.JWT_SECRET, { expiresIn: '7d' }
        );

        res.status(200).json({
            message: 'Login successful!',
            token: token,
            user: {
                id: user.user_id,
                email: user.email,
                role: user.role,
                companyId: companyId // 🚀 SEND THIS BACK TO FLUTTER!
            }
        });

    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Server error during login.' });
    }
};
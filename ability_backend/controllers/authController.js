// controllers/authController.js
const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// --- REGISTER A NEW USER ---
exports.register = async(req, res) => {
    // Grab registration properties from the Flutter request payload
    const { email, password, role, companyName } = req.body;

    if (!email || !password || !role) {
        return res.status(400).json({ message: 'Missing required registration parameters.' });
    }

    // Acquire a singular isolated database connection to perform a secure atomic transaction
    const client = await pool.connect();

    try {
        // Start database transaction pipeline
        await client.query('BEGIN');

        // 1. Check if user already exists
        const { rows: existingUsers } = await client.query('SELECT * FROM users WHERE email = $1', [email]);
        if (existingUsers.length > 0) {
            await client.query('ROLLBACK'); // Cancel transaction
            return res.status(400).json({ message: 'User already exists with this email.' });
        }

        // 2. Hash the password for security
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(password, salt);

        // 3. Insert the new user into the database
        const { rows: insertedUsers } = await client.query(
            'INSERT INTO users (email, password_hash, role) VALUES ($1, $2, $3) RETURNING user_id', [email, passwordHash, role]
        );

        const newUserId = insertedUsers[0].user_id;

        // 4. 🚀 LIFECYCLE LINK: Automatically provision a company container if the registrant is an employer
        if (role === 'employer') {
            // If Flutter didn't supply a companyName text field, generate a clean placeholder string
            const finalCompanyName = companyName || `Company ${newUserId}`;

            // Insert matching company metadata row linked back to our new user_id column
            await client.query(
                `INSERT INTO companies (admin_user_id, company_name, reality_score, inclusivity_tier)
                 VALUES ($1, $2, 1.00, 'None')`, [newUserId, finalCompanyName]
            );

            console.log(`🏢 [REGISTRATION LOG] Created corporate entity profile row for User ID: ${newUserId}`);
        }

        // Commit both inserts into your PostgreSQL system permanently together
        await client.query('COMMIT');
        console.log(`👤 [REGISTRATION SUCCESS] Secure account built for profile entity ID: ${newUserId}`);

        res.status(201).json({
            message: role === 'employer' ? 'Employer and Company registered successfully!' : 'User registered successfully!',
            userId: newUserId
        });

    } catch (error) {
        // Cancel everything if any internal database sequence fails
        await client.query('ROLLBACK');
        console.error('Registration Error:', error);
        res.status(500).json({ message: 'Server error during registration.' });
    } finally {
        // Always release the connection handle back to pool management
        client.release();
    }
};

// --- LOGIN AN EXISTING USER ---
exports.login = async(req, res) => {
    const { email, password } = req.body;

    try {
        // 1. Find the user by email
        const { rows: users } = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found.' });
        }

        const user = users[0];

        // 2. Compare the provided password with the hashed password in DB
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials.' });
        }

        // 3. 🚀 Find their company_id if they are an employer
        let companyId = null;
        if (user.role === 'employer') {
            const { rows: companies } = await pool.query('SELECT company_id FROM companies WHERE admin_user_id = $1', [user.user_id]);
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
                name: user.email.split('@')[0], // Use email prefix as name
                email: user.email,
                role: user.role,
                companyId: companyId // include companyId when available
            }
        });

    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Server error during login.' });
    }
};

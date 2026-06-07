// controllers/jobController.js
const pool = require('../config/db');
const jwt = require('jsonwebtoken');
require('dotenv').config();

// --- POST A NEW JOB (For Employers) ---
exports.createJob = async(req, res) => {
    const { company_id, employer_id, employer_email, title, description, job_type, is_remote, accommodation_offerings } = req.body;

    console.log('POST /api/jobs body:', req.body);

    try {
        let companyId = company_id;
        let employerId = employer_id || null;

        // If employer id is not provided in the body, try to resolve it from the Authorization Bearer token
        if (!employerId) {
            const authHeader = req.headers.authorization || '';
            if (authHeader.startsWith('Bearer ')) {
                const token = authHeader.split(' ')[1];
                try {
                    const decoded = jwt.verify(token, process.env.JWT_SECRET);
                    employerId = decoded.userId || decoded.user_id || null;
                    console.log('Resolved employerId from JWT:', employerId);
                } catch (e) {
                    console.warn('Failed to verify JWT in createJob:', e.message);
                }
            }
        }

        if (!companyId) {
            if (employer_email) {
                const { rows: companyResult } = await pool.query(
                    `SELECT c.company_id
                     FROM companies c
                     INNER JOIN users u ON c.admin_user_id = u.user_id
                     WHERE u.email = $1 LIMIT 1`, [employer_email]
                );

                if (companyResult.length > 0) {
                    companyId = companyResult[0].company_id;
                }
            }

            if (!companyId && employer_id) {
                const { rows: companyResult } = await pool.query(
                    `SELECT company_id FROM companies WHERE admin_user_id = $1 LIMIT 1`, [employer_id]
                );

                if (companyResult.length > 0) {
                    companyId = companyResult[0].company_id;
                }
            }
        }

        if (!companyId) {
            // If there is no company profile, attempt to create a lightweight company
            // so employers can post immediately from the client. We prefer using
            // the employer_id as the admin_user_id when available, otherwise
            // we fallback to resolving via employer_email which we may have looked up earlier.
            try {
                const companyNameFallback = employer_email || `Company for user ${employer_id || 'unknown'}`;
                const adminUserId = employer_id || null;

                // If we have an admin user id, create the company and continue
                if (adminUserId) {
                    const { rows: createRes } = await pool.query(
                        `INSERT INTO companies (company_name, admin_user_id) VALUES ($1, $2) RETURNING company_id`, [companyNameFallback, adminUserId]
                    );

                    companyId = createRes[0].company_id;
                    // If we created the company using the admin user id, ensure employerId is set
                    employerId = employerId || adminUserId;
                    console.log('Created fallback company', { companyId, adminUserId });
                } else {
                    return res.status(404).json({ message: 'No company profile found for this employer.' });
                }
            } catch (createError) {
                console.error('Error creating fallback company:', createError);
                return res.status(500).json({ message: 'Failed to create company profile for employer.' });
            }
        }
        // Ensure employer_id is included on job listings so employer dashboard queries match
        const { rows: insertResult } = await pool.query(
            `INSERT INTO job_listings
            (company_id, employer_id, title, description, job_type, is_remote, accommodation_offerings)
            VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING job_id`, [
                companyId,
                employerId,
                title,
                description,
                job_type,
                is_remote,
                JSON.stringify(accommodation_offerings || [])
            ]
        );

        const newJobId = insertResult[0].job_id;
        console.log('Inserted job listing id:', newJobId);

        // Return the inserted row for client verification
        const { rows: insertedRows } = await pool.query('SELECT j.job_id, j.company_id, j.employer_id, j.title, j.description, j.created_at FROM job_listings j WHERE j.job_id = $1', [newJobId]);

        res.status(201).json({
            message: 'Job posted successfully!',
            job: insertedRows[0] || null
        });
    } catch (error) {
        console.error('Error posting job:', error);
        res.status(500).json({ message: 'Server error while posting job.' });
    }
};

// --- GET ALL JOBS (For Seekers) ---
exports.getJobs = async(req, res) => {
    try {
        const { rows: jobs } = await pool.query(`
            SELECT
                j.job_id,
                j.company_id,
                j.employer_id,
                j.title,
                j.description,
                j.job_type,
                j.is_remote,
                j.created_at,
                j.accommodation_offerings AS accommodations,
                c.company_name
            FROM job_listings j
            JOIN companies c ON j.company_id = c.company_id
            ORDER BY j.created_at DESC
        `);

        res.status(200).json(jobs);
    } catch (error) {
        console.error('Error fetching jobs:', error);
        res.status(500).json({ message: 'Server error while fetching jobs.' });
    }
};

// --- GET EMPLOYER SPECIFIC DASHBOARD DATA ---
exports.getEmployerDashboard = async(req, res) => {
    const { email } = req.query;

    try {
        if (!email) {
            return res.status(400).json({ message: 'Employer email query parameter is required.' });
        }

        const { rows: companyResult } = await pool.query(
            `SELECT c.company_id, c.admin_user_id
             FROM companies c
             INNER JOIN users u ON c.admin_user_id = u.user_id
             WHERE u.email = $1 LIMIT 1`, [email]
        );

        if (companyResult.length === 0) {
            return res.status(200).json({
                stats: { totalPosts: 0, totalApps: 0, interviews: 0 },
                jobs: []
            });
        }

        const companyId = companyResult[0].company_id;

        // Fetch jobs by company_id so existing job_listings without employer_id still show
        const { rows: jobs } = await pool.query(
            `SELECT j.job_id, j.company_id, j.employer_id, j.title, j.description, j.job_type, j.is_remote, j.created_at,
                    j.accommodation_offerings AS accommodations, c.company_name,
                    (SELECT COUNT(*)::int FROM applications WHERE job_id = j.job_id) as "applicantCount"
            FROM job_listings j
            JOIN companies c ON j.company_id = c.company_id
            WHERE j.company_id = $1
            ORDER BY j.created_at DESC`, [companyId]
        );

        const dynamicTotalPosts = jobs.length;

        const { rows: appCountForJobs } = await pool.query(`
            SELECT COUNT(*)::int as "totalApps"
            FROM applications a
            JOIN job_listings j ON a.job_id = j.job_id
            WHERE j.company_id = $1
        `, [companyId]);

        const { rows: interviewCountForJobs } = await pool.query(`
            SELECT COUNT(*)::int as "totalInterviews"
            FROM applications a
            JOIN job_listings j ON a.job_id = j.job_id
            WHERE j.company_id = $1 AND LOWER(a.status) IN ('interview_offered', 'interview offered')
        `, [companyId]);

        res.status(200).json({
            stats: {
                totalPosts: dynamicTotalPosts,
                totalApps: appCountForJobs[0].totalApps || 0,
                interviews: interviewCountForJobs[0].totalInterviews || 0
            },
            jobs: jobs
        });

    } catch (error) {
        console.error('Error fetching employer dashboard payload:', error);
        res.status(500).json({ message: 'Server error processing dashboard query.' });
    }
};

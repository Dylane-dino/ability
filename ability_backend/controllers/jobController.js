// controllers/jobController.js
const pool = require('../config/db');

// --- POST A NEW JOB (For Employers) ---
exports.createJob = async(req, res) => {
    const { company_id, employer_id, employer_email, title, description, job_type, is_remote, accommodation_offerings } = req.body;

    try {
        let companyId = company_id;

        if (!companyId) {
            if (employer_email) {
                const [companyResult] = await pool.query(
                    `SELECT c.company_id
                     FROM companies c
                     INNER JOIN users u ON c.admin_user_id = u.user_id
                     WHERE u.email = ? LIMIT 1`, [employer_email]
                );

                if (companyResult.length > 0) {
                    companyId = companyResult[0].company_id;
                }
            }

            if (!companyId && employer_id) {
                const [companyResult] = await pool.query(
                    `SELECT company_id FROM companies WHERE admin_user_id = ? LIMIT 1`, [employer_id]
                );

                if (companyResult.length > 0) {
                    companyId = companyResult[0].company_id;
                }
            }
        }

        if (!companyId) {
            return res.status(404).json({ message: 'No company profile found for this employer.' });
        }

        const [result] = await pool.query(
            `INSERT INTO job_listings 
            (company_id, title, description, job_type, is_remote, accommodation_offerings) 
            VALUES (?, ?, ?, ?, ?, ?)`, [
                companyId,
                title,
                description,
                job_type,
                is_remote,
                JSON.stringify(accommodation_offerings || [])
            ]
        );

        res.status(201).json({
            message: 'Job posted successfully!',
            jobId: result.insertId
        });
    } catch (error) {
        console.error('Error posting job:', error);
        res.status(500).json({ message: 'Server error while posting job.' });
    }
};

// --- GET ALL JOBS (For Seekers) ---
exports.getJobs = async(req, res) => {
    try {
        const [jobs] = await pool.query(`
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

        const [companyResult] = await pool.query(
            `SELECT c.company_id, c.admin_user_id 
             FROM companies c
             INNER JOIN users u ON c.admin_user_id = u.user_id
             WHERE u.email = ? LIMIT 1`, [email]
        );

        if (companyResult.length === 0) {
            return res.status(200).json({
                stats: { totalPosts: 0, totalApps: 0, interviews: 0 },
                jobs: []
            });
        }

        const adminUserId = companyResult[0].admin_user_id;

        const [jobs] = await pool.query(
            `SELECT j.job_id, j.company_id, j.title, j.description, j.job_type, j.is_remote, j.created_at,
                    j.accommodation_offerings AS accommodations, c.company_name,
                    (SELECT COUNT(*) FROM applications WHERE job_id = j.job_id) as applicantCount
            FROM job_listings j
            JOIN companies c ON j.company_id = c.company_id
            WHERE j.employer_id = ?
            ORDER BY j.created_at DESC`, [adminUserId]
        );

        const dynamicTotalPosts = jobs.length;

        const [appCountForJobs] = await pool.query(`
            SELECT COUNT(*) as totalApps
            FROM applications a
            JOIN job_listings j ON a.job_id = j.job_id
            WHERE j.employer_id = ?
        `, [adminUserId]);

        const [interviewCountForJobs] = await pool.query(`
            SELECT COUNT(*) as totalInterviews
            FROM applications a
            JOIN job_listings j ON a.job_id = j.job_id
            WHERE j.employer_id = ? AND LOWER(a.status) IN ('interview_offered', 'interview offered')
        `, [adminUserId]);

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
const pool = require('../config/db');

exports.getEmployerDashboardStats = async(req, res) => {
    const { employerId } = req.params;

    try {
        const [jobCountResult] = await pool.query(
            'SELECT COUNT(*) as totalPosts FROM job_listings WHERE employer_id = ?', [employerId]
        );

        const [appCountResult] = await pool.query(`
            SELECT COUNT(*) as totalApps
            FROM applications a
            JOIN job_listings j ON a.job_id = j.job_id
            WHERE j.employer_id = ?
        `, [employerId]);

        const [interviewCountResult] = await pool.query(`
            SELECT COUNT(*) as totalInterviews
            FROM applications a
            JOIN job_listings j ON a.job_id = j.job_id
            WHERE j.employer_id = ? AND LOWER(a.status) IN ('interview_offered', 'interview offered')
        `, [employerId]);

        const [jobs] = await pool.query(`
            SELECT
                j.job_id,
                j.company_id,
                j.employer_id,
                j.title,
                j.description,
                j.job_type,
                j.is_remote,
                j.accommodation_offerings,
                j.created_at,
                c.company_name,
                (SELECT COUNT(*) FROM applications WHERE job_id = j.job_id) as applicantCount
            FROM job_listings j
            JOIN companies c ON j.company_id = c.company_id
            WHERE j.employer_id = ?
            ORDER BY j.created_at DESC
        `, [employerId]);

        res.status(200).json({
            stats: {
                totalPosts: jobCountResult[0].totalPosts || 0,
                totalApps: appCountResult[0].totalApps || 0,
                interviews: interviewCountResult[0].totalInterviews || 0
            },
            jobs: jobs
        });

    } catch (error) {
        console.error('Error fetching employer dashboard:', error);
        res.status(500).json({
            stats: { totalPosts: 0, totalApps: 0, interviews: 0 },
            jobs: []
        });
    }
};

exports.getEmployerActiveJobs = async(req, res) => {
    const { employerId } = req.params;
    try {
        const [jobs] = await pool.query(
            'SELECT * FROM job_listings WHERE employer_id = ? ORDER BY created_at DESC', [employerId]
        );
        res.status(200).json(jobs);
    } catch (error) {
        console.error('Error fetching employer jobs:', error);
        res.status(500).json({ message: 'Server error pulling job records.' });
    }
};

exports.getEmployerJobsWithStats = async(req, res) => {
    const { employerId } = req.params;

    try {
        const [jobsWithApps] = await pool.query(
            `SELECT 
                j.job_id,
                j.title,
                j.created_at,
                COUNT(a.application_id) as applicationCount
            FROM job_listings j
            LEFT JOIN applications a ON j.job_id = a.job_id
            WHERE j.employer_id = ?
            GROUP BY j.job_id
            ORDER BY j.created_at DESC`,
            [employerId]
        );

        res.status(200).json(jobsWithApps);
    } catch (error) {
        console.error('Error fetching employer jobs with stats:', error);
        res.status(500).json({ message: 'Server error.' });
    }
};
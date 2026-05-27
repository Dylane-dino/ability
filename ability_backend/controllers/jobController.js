// controllers/jobController.js
const pool = require('../config/db');

// --- POST A NEW JOB (For Employers) ---
exports.createJob = async(req, res) => {
    // Flutter will send these details when an employer posts a job
    const { companyId, title, description, jobType, isRemote, accommodations } = req.body;

    try {
        // Insert the job into the database
    const [result] = await pool.query(
            `INSERT INTO job_listings 
            (company_id, title, description, job_type, is_remote, accommodation_offerings) 
            VALUES (?, ?, ?, ?, ?, ?)`, [
                companyId,
                title,
                description,
                jobType,
                isRemote ? 1 : 0,
                JSON.stringify(accommodations)
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
// --- GET ALL JOBS (For Seekers) ---
exports.getJobs = async(req, res) => {
    try {
        // 🚀 NEW: We use "AS accommodations" to rename the column so Flutter understands it!
        const [jobs] = await pool.query(`
            SELECT 
                j.job_id, 
                j.company_id, 
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
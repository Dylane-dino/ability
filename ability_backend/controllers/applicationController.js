// controllers/applicationController.js
const pool = require('../config/db');

// --- SUBMIT A JOB APPLICATION (Seeker) ---
exports.createApplication = async (req, res) => {
  const { job_id, seeker_id, cover_letter } = req.body;

  try {
    // 1. Check if job exists
    const [jobs] = await pool.query('SELECT * FROM job_listings WHERE job_id = ?', [job_id]);
    if (jobs.length === 0) {
      return res.status(404).json({ message: 'Job not found.' });
    }

    // 2. Check if seeker exists
    const [seekers] = await pool.query('SELECT * FROM users WHERE user_id = ? AND role = ?', [seeker_id, 'seeker']);
    if (seekers.length === 0) {
      return res.status(404).json({ message: 'Seeker not found.' });
    }

    // 3. Check if already applied
    const [existing] = await pool.query('SELECT * FROM applications WHERE job_id = ? AND seeker_id = ?', [job_id, seeker_id]);
    if (existing.length > 0) {
      return res.status(400).json({ message: 'Already applied to this job.' });
    }

    // 4. Insert application
    const [result] = await pool.query(
      'INSERT INTO applications (job_id, seeker_id, cover_letter, status) VALUES (?, ?, ?, ?)',
      [job_id, seeker_id, cover_letter, 'pending']
    );

    res.status(201).json({
      message: 'Application submitted successfully!',
      applicationId: result.insertId,
    });
  } catch (error) {
    console.error('Application Error:', error);
    res.status(500).json({ message: 'Server error during application.' });
  }
};

// --- GET APPLICATIONS FOR A SPECIFIC JOB (Employer) ---
exports.getJobApplications = async (req, res) => {
  const { jobId } = req.params;

  try {
    const query = `
      SELECT 
        a.application_id,
        a.job_id,
        a.seeker_id,
        a.cover_letter,
        a.status,
        a.applied_at,
        u.full_name AS seeker_name,
        u.email AS seeker_email,
        p.bio,
        j.title AS job_title,
        c.company_name
      FROM applications a
      JOIN users u ON a.seeker_id = u.user_id
      LEFT JOIN seeker_profiles p ON u.user_id = p.user_id
      JOIN job_listings j ON a.job_id = j.job_id
      JOIN companies c ON j.company_id = c.company_id
      WHERE a.job_id = ?
      ORDER BY a.applied_at DESC
    `;

    const [rows] = await pool.query(query, [jobId]);
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error fetching job applications:', error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// --- GET APPLICATIONS BY SEEKER ID (Seeker's applied jobs) ---
exports.getSeekerApplications = async (req, res) => {
  const { seekerId } = req.params;

  try {
    const query = `
      SELECT 
        a.application_id,
        a.job_id,
        a.seeker_id,
        a.cover_letter,
        a.status,
        a.applied_at,
        u.full_name AS seeker_name,
        j.title AS job_title,
        j.description,
        j.job_type,
        j.is_remote,
        c.company_name,
        c.company_id
      FROM applications a
      JOIN users u ON a.seeker_id = u.user_id
      JOIN job_listings j ON a.job_id = j.job_id
      JOIN companies c ON j.company_id = c.company_id
      WHERE a.seeker_id = ?
      ORDER BY a.applied_at DESC
    `;

    const [rows] = await pool.query(query, [seekerId]);
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error fetching seeker applications:', error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// --- UPDATE APPLICATION STATUS (Employer) ---
exports.updateApplicationStatus = async (req, res) => {
  const { applicationId } = req.params;
  const { status } = req.body;

  const validStatuses = ['pending', 'viewed', 'interview_offered', 'accepted', 'rejected'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ message: 'Invalid status.' });
  }

  try {
    const [result] = await pool.query(
      'UPDATE applications SET status = ? WHERE application_id = ?',
      [status, applicationId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Application not found.' });
    }

    res.status(200).json({ message: 'Status updated successfully.' });
  } catch (error) {
    console.error('Error updating status:', error);
    res.status(500).json({ message: 'Server error.' });
  }
};

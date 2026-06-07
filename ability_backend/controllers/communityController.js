const pool = require('../config/db');

// --- GET ALL LEARNING RESOURCES ---
exports.getLearningResources = async(req, res) => {
    try {
        const [resources] = await pool.query(
            'SELECT resource_id as id, title, description, icon_name, lessons_count FROM learning_resources ORDER BY created_at DESC'
        );
        res.status(200).json(resources);
    } catch (error) {
        console.error('Error fetching learning resources:', error);
        res.status(500).json({ message: 'Server error fetching learning resources.' });
    }
};

// --- GET ALL MENTORS ---
exports.getMentors = async(req, res) => {
    try {
        // Return fields that match the frontend expectations: id, name, role, tag, experience
        const [mentors] = await pool.query(
            'SELECT mentor_id as id, name, role, expertise as tag, experience FROM mentors WHERE available = TRUE'
        );
        res.status(200).json(mentors);
    } catch (error) {
        console.error('Error fetching mentors:', error);
        res.status(500).json({ message: 'Server error fetching mentors.' });
    }
};

// --- POST MENTORSHIP REQUEST ---
exports.requestMentorship = async(req, res) => {
    const { seeker_id, mentor_id, message } = req.body;

    try {
        if (!seeker_id || !mentor_id) {
            return res.status(400).json({ message: 'Seeker ID and Mentor ID are required.' });
        }

        const [result] = await pool.query(
            'INSERT INTO mentorship_requests (seeker_id, mentor_id, message) VALUES (?, ?, ?)',
            [seeker_id, mentor_id, message || '']
        );

        res.status(201).json({
            message: 'Mentorship request sent successfully!',
            requestId: result.insertId
        });
    } catch (error) {
        console.error('Error requesting mentorship:', error);
        res.status(500).json({ message: 'Server error sending mentorship request.' });
    }
};

// --- GET ALL FORUM POSTS ---
exports.getForumPosts = async(req, res) => {
    try {
        const [posts] = await pool.query(
            'SELECT post_id as id, title, category, upvotes, replies_count as replies FROM forum_posts ORDER BY created_at DESC'
        );
        res.status(200).json(posts);
    } catch (error) {
        console.error('Error fetching forum posts:', error);
        res.status(500).json({ message: 'Server error fetching forum posts.' });
    }
};

// --- CREATE A MENTOR (Admin or Seeder) ---
exports.createMentor = async (req, res) => {
    try {
        const { name, role, expertise, experience, available } = req.body;

        if (!name) {
            return res.status(400).json({ message: 'name is required' });
        }

        const isAvailable = available === undefined ? true : !!available;

        const [result] = await pool.query(
            'INSERT INTO mentors (name, role, expertise, experience, available, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
            [name, role || 'Mentor', expertise || 'General', experience || '', isAvailable]
        );

        const [rows] = await pool.query('SELECT mentor_id as id, name, role, expertise as tag, experience FROM mentors WHERE mentor_id = ?', [result.insertId]);
        res.status(201).json(rows[0]);
    } catch (error) {
        console.error('Error creating mentor:', error);
        res.status(500).json({ message: 'Server error creating mentor.' });
    }
};
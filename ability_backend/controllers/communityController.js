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
        const [mentors] = await pool.query(
            'SELECT mentor_id as id, name, role, expertise as tag, experience as exp FROM mentors WHERE available = TRUE'
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
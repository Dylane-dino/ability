// controllers/messagesController.js
const pool = require('../config/db');

// --- GET CONVERSATION BETWEEN TWO USERS (OPTIONAL JOB CONTEXT) ---
exports.getConversation = async (req, res) => {
  const { userId, otherUserId, jobId } = req.query;

  try {
    let query = `
      SELECT
        m.message_id,
        m.sender_id,
        m.receiver_id,
        m.content,
        m.media_url,
        m.sent_at,
        u1.full_name AS sender_name,
        u2.full_name AS receiver_name
      FROM messages m
      JOIN users u1 ON m.sender_id = u1.user_id
      JOIN users u2 ON m.receiver_id = u2.user_id
      WHERE (
        (m.sender_id = $1 AND m.receiver_id = $2)
        OR
        (m.sender_id = $2 AND m.receiver_id = $1)
      )
    `;

    const params = [userId, otherUserId];

    if (jobId != null) {
      query += ` AND m.job_id = $${params.length + 1}`;
      params.push(jobId);
    }

    query += ' ORDER BY m.sent_at ASC';

    const { rows } = await pool.query(query, params);
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error fetching conversation:', error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// --- GET ALL CONVERSATIONS FOR A USER (list of chat partners) ---
exports.getConversations = async (req, res) => {
  const { userId } = req.query;

  try {
    // Fetch all messages involving this user with partner names
    const query = `
      SELECT
        m.message_id,
        m.sender_id,
        m.receiver_id,
        m.content,
        m.sent_at,
        u1.full_name AS sender_name,
        u2.full_name AS receiver_name
      FROM messages m
      JOIN users u1 ON m.sender_id = u1.user_id
      JOIN users u2 ON m.receiver_id = u2.user_id
      WHERE m.sender_id = $1 OR m.receiver_id = $1
      ORDER BY m.sent_at DESC
    `;

    const { rows } = await pool.query(query, [userId]);

    // Build conversation summary
    const convos = {};
    rows.forEach(row => {
      const otherId = row.sender_id == userId ? row.receiver_id : row.sender_id;
      const otherName = row.sender_id == userId ? row.receiver_name : row.sender_name;

      if (!convos[otherId]) {
        convos[otherId] = {
          other_user_id: otherId,
          other_user_name: otherName,
          last_message: row.content,
          last_message_time: row.sent_at,
          total_messages: 0,
        };
      }
      convos[otherId].total_messages++;
    });

    const result = Object.values(convos);
    res.status(200).json(result);
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// --- SEND A MESSAGE ---
exports.sendMessage = async (req, res) => {
  const { sender_id, receiver_id, job_id, content } = req.body;

  try {
    // Verify sender exists
    const { rows: senders } = await pool.query('SELECT * FROM users WHERE user_id = $1', [sender_id]);
    if (senders.length === 0) {
      return res.status(404).json({ message: 'Sender not found.' });
    }

    // Verify receiver exists
    const { rows: receivers } = await pool.query('SELECT * FROM users WHERE user_id = $1', [receiver_id]);
    if (receivers.length === 0) {
      return res.status(404).json({ message: 'Receiver not found.' });
    }

    // Optional: verify job exists if provided
    if (job_id != null) {
      const { rows: jobs } = await pool.query('SELECT * FROM job_listings WHERE job_id = $1', [job_id]);
      if (jobs.length === 0) {
        return res.status(404).json({ message: 'Job not found.' });
      }
    }

    const { rows: insertedMessages } = await pool.query(
      'INSERT INTO messages (sender_id, receiver_id, job_id, content) VALUES ($1, $2, $3, $4) RETURNING message_id',
      [sender_id, receiver_id, job_id, content]
    );

    // Fetch created message with sender/receiver names for response
    const { rows: newMsg } = await pool.query(`
      SELECT
        m.*,
        s.full_name AS sender_name,
        r.full_name AS receiver_name
      FROM messages m
      JOIN users s ON m.sender_id = s.user_id
      JOIN users r ON m.receiver_id = r.user_id
      WHERE m.message_id = $1
    `, [insertedMessages[0].message_id]);

    res.status(201).json(newMsg[0]);
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Server error.' });
  }
};

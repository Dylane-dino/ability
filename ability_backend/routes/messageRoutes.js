// routes/messageRoutes.js
const express = require('express');
const router = express.Router();
const messagesController = require('../controllers/messagesController');

// POST /api/messages - Send a message
router.post('/', messagesController.sendMessage);

// GET /api/messages/conversation - Get conversation between two users
router.get('/conversation', messagesController.getConversation);

// GET /api/messages/conversations - Get all conversations for a user
router.get('/conversations', messagesController.getConversations);

module.exports = router;

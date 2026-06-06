const express = require('express');
const router = express.Router();
const communityController = require('../controllers/communityController');

router.get('/learning', communityController.getLearningResources);
router.get('/mentors', communityController.getMentors);
router.get('/forum', communityController.getForumPosts);
router.post('/mentorship-request', communityController.requestMentorship);

module.exports = router;
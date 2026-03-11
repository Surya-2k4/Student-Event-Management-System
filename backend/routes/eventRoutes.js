const express = require('express');
const router = express.Router();
const eventController = require('../controllers/eventController');
const verifyToken = require('../middleware/auth');

router.post('/register-event', verifyToken, eventController.registerEvent);
router.get('/view-events', verifyToken, eventController.getEvents);

module.exports = router;

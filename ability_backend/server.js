const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/db');
const jobRoutes = require('./routes/jobRoutes');
const applicationRoutes = require('./routes/applicationRoutes');
const messageRoutes = require('./routes/messageRoutes');
const companyRoutes = require('./routes/companyRoutes');
const employerRoutes = require('./routes/employerRoutes');
const communityRoutes = require('./routes/communityRoutes');
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Import Routes
const authRoutes = require('./routes/authRoutes');

// Use Routes
app.use('/api/auth', authRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/companies', companyRoutes);
app.use('/api/employers', employerRoutes);
app.use('/api/community', communityRoutes);

// Health check
app.get('/', (req, res) => {
    res.send('AbilityBridge API is running...');
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running on port ${PORT} (Accepting outside connections)`);
});
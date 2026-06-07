const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DATABASE_URL && process.env.DATABASE_URL.includes('sslmode=require')
        ? { rejectUnauthorized: false }
        : false
});

// Test the connection
pool.connect()
    .then(client => {
        console.log('✅ Connected to PostgreSQL Database: ability_bridge');
        client.release();
    })
    .catch(err => {
        console.error('❌ PostgreSQL Connection Error:', err.message);
    });

module.exports = pool;

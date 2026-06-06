const http = require('http');

const testAll = () => {
    // Test getCompanyAdmin
    http.get('http://localhost:3000/api/companies/1/admin', (res) => {
        let d = '';
        res.on('data', c => d += c);
        res.on('end', () => console.log('/companies/1/admin:', res.statusCode, d.substring(0, 100)));
    });

    // Test apply to job
    const data = JSON.stringify({ job_id: 1, seeker_id: 1 });
    http.request({
        hostname: 'localhost',
        port: 3000,
        path: '/api/applications',
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': data.length }
    }, (res) => {
        let d = '';
        res.on('data', c => d += c);
        res.on('end', () => console.log('/applications POST:', res.statusCode, d));
    }).end(data);

    // Test get job applications
    http.get('http://localhost:3000/api/applications/job/1', (res) => {
        let d = '';
        res.on('data', c => d += c);
        res.on('end', () => console.log('/applications/job/1:', res.statusCode, d.substring(0, 100)));
    });
};

testAll();
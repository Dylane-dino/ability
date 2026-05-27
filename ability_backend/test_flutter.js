const http = require('http');

const data = JSON.stringify({
    email: 'flutter@test.com',
    password: 'flutter123',
    role: 'seeker'
});

const options = {
    hostname: '10.244.16.141',
    port: 3000,
    path: '/api/auth/register',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

const req = http.request(options, (res) => {
    let body = '';
    res.on('data', (chunk) => body += chunk);
    res.on('end', () => {
        console.log('Status:', res.statusCode);
        console.log('Response:', body);
    });
});

req.on('error', (e) => console.log('Error:', e.message));
req.write(data);
req.end();
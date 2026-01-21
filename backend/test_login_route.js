const axios = require('axios');

async function testLogin() {
    try {
        console.log('Testing: https://rockster-production.up.railway.app/api/auth/login');
        const response = await axios.post('https://rockster-production.up.railway.app/api/auth/login', {
            email: 'test@test.com',
            password: 'wrongpassword'
        });
        console.log('Success:', response.status, response.data);
    } catch (error) {
        if (error.response) {
            console.log('Server Responded:', error.response.status, error.response.data);
        } else {
            console.log('Network Error:', error.message);
        }
    }
}

testLogin();

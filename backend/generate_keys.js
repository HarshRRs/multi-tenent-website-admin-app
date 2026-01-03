const crypto = require('crypto');
const fs = require('fs');

const key1 = crypto.randomBytes(32).toString('hex');
const key2 = crypto.randomBytes(32).toString('hex');

fs.writeFileSync('keys.txt', `JWT_SECRET=${key1}\nJWT_REFRESH_SECRET=${key2}`);
console.log('Keys generated to keys.txt');

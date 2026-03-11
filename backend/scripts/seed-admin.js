const db = require('../config/db');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function seedAdmin() {
  const name = 'Super Admin';
  const email = 'admin@kongu.edu';
  const password = 'konguadmin@mca';
  const role = 'Admin';

  try {
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL is not defined in your .env file');
    }
    console.log('Connecting to database...');
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Check if user exists
    const check = await db.query('SELECT id FROM users WHERE email = $1', [email]);
    
    if (check.rows.length > 0) {
      console.log('Updating existing admin user...');
      await db.query(
        'UPDATE users SET password = $1, role = $2, name = $3 WHERE email = $4',
        [hashedPassword, role, name, email]
      );
    } else {
      console.log('Creating new admin user...');
      await db.query(
        'INSERT INTO users (name, email, password, role) VALUES ($1, $2, $3, $4)',
        [name, email, hashedPassword, role]
      );
    }
    
    console.log('✅ Admin user processed successfully!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error seeding admin:', err);
    process.exit(1);
  }
}

seedAdmin();

const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  try {
    const { name, rollNumber, email, password } = req.body;

    // Check existing email
    const emailCheck = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (emailCheck.rows.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    // Check existing roll number
    const rollCheck = await db.query('SELECT * FROM users WHERE roll_number = $1', [rollNumber]);
    if (rollCheck.rows.length > 0) {
      return res.status(400).json({ message: "Roll Number already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await db.query(
      'INSERT INTO users (name, roll_number, email, password, role) VALUES ($1, $2, $3, $4, $5) RETURNING id, name, email, roll_number, role',
      [name, rollNumber, email, hashedPassword, 'Student']
    );

    res.status(201).json({ message: "User Registered", user: result.rows[0] });
  } catch (error) {
    console.error(error);
    if (error.code === '23505') {
      return res.status(400).json({ message: "An account with this data already exists." });
    }
    res.status(500).json({ message: "Server error" });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      return res.status(400).json({ message: "User Not Found" });
    }

    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid Credentials" });
    }

    const token = jwt.sign({ userId: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: "24h" });
    
    // Don't send password back
    const { password: _, ...userWithoutPassword } = user;
    res.json({ token, user: userWithoutPassword });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ message: "Server error: " + error.message });
  }
};

exports.createStaff = async (req, res) => {
  try {
    if (req.user.role !== 'Admin') {
      return res.status(403).json({ message: "Only Admin can create staff logins" });
    }

    const { name, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    
    await db.query(
      'INSERT INTO users (name, email, password, role) VALUES ($1, $2, $3, $4)',
      [name, email, hashedPassword, 'Staff']
    );
    
    res.status(201).json({ message: "Staff created successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getUser = async (req, res) => {
  try {
    const { email } = req.query;
    const result = await db.query('SELECT name, roll_number as "rollNumber", email, role FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

exports.updateProfile = async (req, res) => {
    try {
      const { name, rollNumber, email, password, userId } = req.body;
      const hashedPassword = await bcrypt.hash(password, 10);
      await db.query(
          'UPDATE users SET name = $1, roll_number = $2, email = $3, password = $4 WHERE id = $5',
          [name, rollNumber, email, hashedPassword, userId]
      );
      res.json({ message: "User Updated" });
    } catch (error) {
      res.status(500).json({ message: "Server error" });
    }
};

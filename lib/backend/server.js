
const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(express.json());
app.use(cors());

mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("MongoDB Connected"))
    .catch(err => console.log(err));

// User Schema
const UserSchema = new mongoose.Schema({
    name: String,
    rollNumber: String,
    email: String,
    password: String
});
const User = mongoose.model("User", UserSchema);

const EventSchema = new mongoose.Schema({
    name: String,
    email: String,
    eventName: String,
    college: String,
    contact: String,
    rollNumber: String,
    symposiumName: String,
    eventType: String,
    teamOrIndividual: String,
    teamMembers: String,
    eventDate: String,
    eventDaysSpent: Number,
    prizeAmount: Number,
    positionSecured: String,
    certificationLink: String,
    interOrIntraEvent: String, // Added field
    date: { type: Date, default: Date.now },
});

const Event = mongoose.model("Event", EventSchema);

// Event Registration Route
app.post("/register-event", async (req, res) => {
  try {
    const {
      name, email, eventName, college, contact, rollNumber, symposiumName,
      eventType, teamOrIndividual, teamMembers, eventDate, eventDaysSpent,
      prizeAmount, positionSecured, certificationLink, interOrIntraEvent // Added field
    } = req.body;

    if (!name || !email || !eventName || !college || !contact || !rollNumber ||
        !symposiumName || !eventType || !teamOrIndividual || !teamMembers ||
        !eventDate || !eventDaysSpent || !prizeAmount || !positionSecured ||
        !certificationLink || !interOrIntraEvent) { // Added field
      return res.status(400).json({ message: "All fields are required" });
    }

    const newEvent = new Event({
      name, email, eventName, college, contact, rollNumber, symposiumName,
      eventType, teamOrIndividual, teamMembers, eventDate, eventDaysSpent,
      prizeAmount, positionSecured, certificationLink, interOrIntraEvent // Added field
    });
    await newEvent.save();

    res.status(201).json({ message: "Event registered successfully!" });
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
});

// View Events Route with Filtering
app.get("/view-events", async (req, res) => {
  try {
    const { email, fromDate, toDate, year, month, eventType, symposiumName, college, interOrIntraEvent , position} = req.query;
    let query = {};

    if (email) query.email = email;
    if (fromDate && toDate) query.eventDate = { $gte: new Date(fromDate), $lte: new Date(toDate) };
    if (year) query.eventDate = { $regex: `^${year}`, $options: "i" };
    if (month) query.eventDate = { $regex: `-${month}-`, $options: "i" };
    if (eventType) query.eventType = { $regex: eventType, $options: "i" };
    if (symposiumName) query.symposiumName = { $regex: symposiumName, $options: "i" };
    if (college) query.college = { $regex: college, $options: "i" };
    if (interOrIntraEvent) query.interOrIntraEvent = { $regex: interOrIntraEvent, $options: "i" };
    if (position) query.positionSecured = position;

    const events = await Event.find(query);
    res.status(200).json(events);
  } catch (err) {
    res.status(500).json({ message: "Error fetching events", error: err });
  }
});

// Register Route
app.post("/register", async (req, res) => {
  const { name, rollNumber, email, password } = req.body;

  // Check if the email already exists
  const existingUserByEmail = await User.findOne({ email });
  if (existingUserByEmail) {
    return res.status(400).json({ message: "Email already exists" });
  }

  // Check if the roll number already exists
  const existingUserByRollNumber = await User.findOne({ rollNumber });
  if (existingUserByRollNumber) {
    return res.status(400).json({ message: "Roll number already exists" });
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const newUser = new User({ name, rollNumber, email, password: hashedPassword });
  await newUser.save();
  res.json({ message: "User Registered" });
});

// Login Route
app.post("/login", async (req, res) => {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: "User Not Found" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Invalid Credentials" });

    const token = jwt.sign({ userId: user._id }, "secretKey", { expiresIn: "1h" });
    res.json({ token, user });
});

// Update Profile
app.put("/update", async (req, res) => {
    const { name, rollNumber, email, password, userId } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    await User.findByIdAndUpdate(userId, { name, rollNumber, email, password: hashedPassword });
    res.json({ message: "User Updated" });
});

app.get("/user", async (req, res) => {
  const { email } = req.query;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json({ name: user.name, rollNumber: user.rollNumber, email: user.email });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err });
  }
});

app.listen(5000, "0.0.0.0", () => console.log("Server running on port 5000"));



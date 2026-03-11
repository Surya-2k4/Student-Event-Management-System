const db = require('../config/db');

exports.registerEvent = async (req, res) => {
  try {
    const {
      name, email, eventName, college, contact, rollNumber, symposiumName,
      eventType, teamOrIndividual, teamMembers, eventDate, eventDaysSpent,
      prizeAmount, positionSecured, certificationLink, interOrIntraEvent
    } = req.body;

    const query = `
      INSERT INTO events (
        name, email, event_name, college, contact, roll_number, symposium_name,
        event_type, team_or_individual, team_members, event_date, event_days_spent,
        prize_amount, position_secured, certification_link, inter_or_intra_event
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
      RETURNING id
    `;

    const values = [
      name, email, eventName, college, contact, rollNumber, symposiumName,
      eventType, teamOrIndividual, teamMembers, eventDate, eventDaysSpent,
      prizeAmount, positionSecured, certificationLink, interOrIntraEvent
    ];

    await db.query(query, values);
    res.status(201).json({ message: "Event registered successfully!" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getEvents = async (req, res) => {
  try {
    const { email, fromDate, toDate, year, month, eventType, symposiumName, college, interOrIntraEvent, position } = req.query;
    
    let query = `
      SELECT 
        id, name, email, event_name as "eventName", college, contact, 
        roll_number as "rollNumber", symposium_name as "symposiumName", 
        event_type as "eventType", team_or_individual as "teamOrIndividual", 
        team_members as "teamMembers", event_date as "eventDate", 
        event_days_spent as "eventDaysSpent", prize_amount as "prizeAmount", 
        position_secured as "positionSecured", certification_link as "certificationLink", 
        inter_or_intra_event as "interOrIntraEvent", created_at as "date"
      FROM events WHERE 1=1
    `;
    let params = [];
    let counter = 1;

    if (email) {
      query += ` AND email = $${counter++}`;
      params.push(email);
    }
    if (fromDate && toDate) {
      query += ` AND event_date BETWEEN $${counter++} AND $${counter++}`;
      params.push(fromDate, toDate);
    }
    if (year) {
      query += ` AND EXTRACT(YEAR FROM event_date) = $${counter++}`;
      params.push(year);
    }
    if (month) {
      query += ` AND EXTRACT(MONTH FROM event_date) = $${counter++}`;
      params.push(month);
    }
    if (eventType) {
      query += ` AND event_type ILIKE $${counter++}`;
      params.push(`%${eventType}%`);
    }
    if (symposiumName) {
      query += ` AND symposium_name ILIKE $${counter++}`;
      params.push(`%${symposiumName}%`);
    }
    if (college) {
      query += ` AND college ILIKE $${counter++}`;
      params.push(`%${college}%`);
    }
    if (interOrIntraEvent) {
      query += ` AND inter_or_intra_event ILIKE $${counter++}`;
      params.push(`%${interOrIntraEvent}%`);
    }
    if (position) {
      query += ` AND position_secured = $${counter++}`;
      params.push(position);
    }

    query += ' ORDER BY event_date DESC';

    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching events" });
  }
};

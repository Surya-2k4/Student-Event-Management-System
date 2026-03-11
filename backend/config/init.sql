CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    roll_number VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    event_name VARCHAR(255) NOT NULL,
    college VARCHAR(255) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    roll_number VARCHAR(100) NOT NULL,
    symposium_name VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    team_or_individual VARCHAR(20) NOT NULL,
    team_members TEXT,
    event_date DATE NOT NULL,
    event_days_spent INTEGER NOT NULL,
    prize_amount DECIMAL(10, 2) NOT NULL,
    position_secured VARCHAR(50) NOT NULL,
    certification_link TEXT,
    inter_or_intra_event VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

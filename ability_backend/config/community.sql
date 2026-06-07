-- Learning Resources Table
CREATE TABLE IF NOT EXISTS learning_resources (
    resource_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    icon_name VARCHAR(50),
    lessons_count VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Mentors Table
CREATE TABLE IF NOT EXISTS mentors (
    mentor_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(255),
    expertise VARCHAR(255),
    experience VARCHAR(50),
    available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Forum Posts Table
CREATE TABLE IF NOT EXISTS forum_posts (
    post_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    upvotes INT DEFAULT 0,
    replies_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

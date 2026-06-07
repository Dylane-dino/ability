-- Connect to (or create) the ability_bridge database before running this script.
-- e.g. createdb ability_bridge   then   psql ability_bridge -f database.sql

-- 1. USERS
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('seeker', 'employer', 'mentor', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE
);

-- 2. SEEKER RESUMES (stores CV/experience)
CREATE TABLE IF NOT EXISTS seeker_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    full_name VARCHAR(100),
    location VARCHAR(150),
    bio TEXT,
    resume_text TEXT, -- Plain-text resume content
    anonymous_apply_mode BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 5. COMPANIES (FR6) -- created before job_listings/applications because they reference it
CREATE TABLE IF NOT EXISTS companies (
    company_id SERIAL PRIMARY KEY,
    admin_user_id INT NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    reality_score DECIMAL(3,2) DEFAULT 0.00,
    inclusivity_tier VARCHAR(10) DEFAULT 'None' CHECK (inclusivity_tier IN ('None', 'Bronze', 'Silver', 'Gold')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 6. JOB LISTINGS (FR3/FR4)
CREATE TABLE IF NOT EXISTS job_listings (
    job_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    job_type VARCHAR(20) NOT NULL CHECK (job_type IN ('full-time', 'part-time', 'micro-task')),
    is_remote BOOLEAN DEFAULT TRUE,
    accommodation_offerings JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);

-- 3. JOB APPLICATIONS (core of FR5/FR8)
CREATE TABLE IF NOT EXISTS applications (
    application_id SERIAL PRIMARY KEY,
    job_id INT NOT NULL,
    seeker_id INT NOT NULL,
    cover_letter TEXT,
    status VARCHAR(30) DEFAULT 'pending' CHECK (status IN ('pending', 'viewed', 'interview_offered', 'accepted', 'rejected')),
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES job_listings(job_id) ON DELETE CASCADE,
    FOREIGN KEY (seeker_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_application UNIQUE (job_id, seeker_id)
);

-- 4. MESSAGES (FR8)
CREATE TABLE IF NOT EXISTS messages (
    message_id SERIAL PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    job_id INT, -- Optional: tie to a specific job/application context
    content TEXT NOT NULL,
    media_url VARCHAR(255), -- For voice messages
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    FOREIGN KEY (job_id) REFERENCES job_listings(job_id)
);

-- 7. SKILLS & BADGES (FR2)
CREATE TABLE IF NOT EXISTS skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS user_skills (
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    is_verified_badge BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id, skill_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);

-- 8. ACCESSIBILITY SETTINGS (FR1.6)
CREATE TABLE IF NOT EXISTS accessibility_settings (
    setting_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    high_contrast BOOLEAN DEFAULT FALSE,
    screen_reader_mode BOOLEAN DEFAULT FALSE,
    font_size_scale DECIMAL(3,2) DEFAULT 1.00,
    dyslexia_font BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 9. DISABILITY INFO (NFR3)
CREATE TABLE IF NOT EXISTS seeker_disability_info (
    info_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    disability_type VARCHAR(255),
    accommodation_needs_json JSONB,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 10. ACCOMMODATION NEGOTIATION LOG (FR5)
-- Note: Postgres has no "ON UPDATE CURRENT_TIMESTAMP" - bump updated_at from the app layer or add a trigger if needed.
CREATE TABLE IF NOT EXISTS accommodation_negotiations (
    neg_id SERIAL PRIMARY KEY,
    job_id INT NOT NULL,
    seeker_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'agreed', 'declined')),
    final_agreement_log TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES job_listings(job_id),
    FOREIGN KEY (seeker_id) REFERENCES users(user_id)
);

-- 11. REPORTING SYSTEM (FR9)
CREATE TABLE IF NOT EXISTS reports (
    report_id SERIAL PRIMARY KEY,
    reporter_id INT NOT NULL,
    target_company_id INT NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'submitted' CHECK (status IN ('submitted', 'under_review', 'resolved')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(user_id),
    FOREIGN KEY (target_company_id) REFERENCES companies(company_id)
);

-- 12. MENTORSHIP (FR7)
CREATE TABLE IF NOT EXISTS mentorship_profiles (
    mentor_id INT PRIMARY KEY,
    industry VARCHAR(100),
    disability_type_specialty VARCHAR(255),
    bio TEXT,
    availability_status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (mentor_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS mentorship_requests (
    request_id SERIAL PRIMARY KEY,
    mentee_id INT NOT NULL,
    mentor_id INT NOT NULL,
    message TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'completed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mentee_id) REFERENCES users(user_id),
    FOREIGN KEY (mentor_id) REFERENCES mentorship_profiles(mentor_id)
);

-- 13. LEARNING (FR2)
CREATE TABLE IF NOT EXISTS external_courses (
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    provider VARCHAR(100),
    url VARCHAR(500),
    target_skill_id INT,
    FOREIGN KEY (target_skill_id) REFERENCES skills(skill_id)
);

CREATE TABLE IF NOT EXISTS user_learning_history (
    history_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    completion_status VARCHAR(20) DEFAULT 'enrolled' CHECK (completion_status IN ('enrolled', 'completed')),
    certificate_url VARCHAR(500),
    completed_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES external_courses(course_id)
);

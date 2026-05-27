-- Create the database
CREATE DATABASE IF NOT EXISTS ability_bridge;
USE ability_bridge;

-- 1. USERS
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('seeker', 'employer', 'mentor', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE
);

-- 2. SEEKER RESUMES (stores CV/experience)
CREATE TABLE IF NOT EXISTS seeker_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    full_name VARCHAR(100),
    location VARCHAR(150),
    bio TEXT,
    resume_text TEXT, -- Plain-text resume content
    anonymous_apply_mode BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3. JOB APPLICATIONS (core of FR5/FR8)
CREATE TABLE IF NOT EXISTS applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    seeker_id INT NOT NULL,
    cover_letter TEXT,
    status ENUM('pending', 'viewed', 'interview_offered', 'accepted', 'rejected') DEFAULT 'pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES job_listings(job_id) ON DELETE CASCADE,
    FOREIGN KEY (seeker_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (job_id, seeker_id)
);

-- 4. MESSAGES (FR8)
CREATE TABLE IF NOT EXISTS messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
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

-- 5. COMPANIES (FR6)
CREATE TABLE IF NOT EXISTS companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_user_id INT NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    reality_score DECIMAL(3,2) DEFAULT 0.00,
    inclusivity_tier ENUM('None', 'Bronze', 'Silver', 'Gold') DEFAULT 'None',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 6. JOB LISTINGS (FR3/FR4)
CREATE TABLE IF NOT EXISTS job_listings (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    job_type ENUM('full-time', 'part-time', 'micro-task') NOT NULL,
    is_remote BOOLEAN DEFAULT TRUE,
    accommodation_offerings JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);

-- 7. SKILLS & BADGES (FR2)
CREATE TABLE IF NOT EXISTS skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
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
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    high_contrast BOOLEAN DEFAULT FALSE,
    screen_reader_mode BOOLEAN DEFAULT FALSE,
    font_size_scale DECIMAL(3,2) DEFAULT 1.00,
    dyslexia_font BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 9. DISABILITY INFO (NFR3)
CREATE TABLE IF NOT EXISTS seeker_disability_info (
    info_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    disability_type VARCHAR(255),
    accommodation_needs_json JSON,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 10. ACCOMMODATION NEGOTIATION LOG (FR5)
CREATE TABLE IF NOT EXISTS accommodation_negotiations (
    neg_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    seeker_id INT NOT NULL,
    status ENUM('pending', 'agreed', 'declined') DEFAULT 'pending',
    final_agreement_log TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES job_listings(job_id),
    FOREIGN KEY (seeker_id) REFERENCES users(user_id)
);

-- 11. REPORTING SYSTEM (FR9)
CREATE TABLE IF NOT EXISTS reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT NOT NULL,
    target_company_id INT NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('submitted', 'under_review', 'resolved') DEFAULT 'submitted',
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
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    mentee_id INT NOT NULL,
    mentor_id INT NOT NULL,
    message TEXT,
    status ENUM('pending', 'accepted', 'declined', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mentee_id) REFERENCES users(user_id),
    FOREIGN KEY (mentor_id) REFERENCES mentorship_profiles(mentor_id)
);

-- 13. LEARNING (FR2)
CREATE TABLE IF NOT EXISTS external_courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    provider VARCHAR(100),
    url VARCHAR(500),
    target_skill_id INT,
    FOREIGN KEY (target_skill_id) REFERENCES skills(skill_id)
);

CREATE TABLE IF NOT EXISTS user_learning_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    completion_status ENUM('enrolled', 'completed') DEFAULT 'enrolled',
    certificate_url VARCHAR(500),
    completed_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES external_courses(course_id)
);
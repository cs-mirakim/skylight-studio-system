-- ============================================
-- SKYLIGHT STUDIO - POSTGRESQL SCHEMA
-- ============================================

-- Drop existing tables if any (for fresh deployment)
DROP TABLE IF EXISTS feedback CASCADE;
DROP TABLE IF EXISTS class_confirmation CASCADE;
DROP TABLE IF EXISTS class CASCADE;
DROP TABLE IF EXISTS instructor CASCADE;
DROP TABLE IF EXISTS admin CASCADE;
DROP TABLE IF EXISTS password_reset CASCADE;
DROP TABLE IF EXISTS registration CASCADE;

-- Table 1: Registration
CREATE TABLE registration (
    registerID SERIAL PRIMARY KEY,
    userType VARCHAR(10) NOT NULL CHECK (userType IN ('admin', 'instructor')),
    status VARCHAR(10) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    registerDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    adminMessage TEXT
);

-- Table 2: Admin
CREATE TABLE admin (
    adminID SERIAL PRIMARY KEY,
    registerID INTEGER NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    nric VARCHAR(20),
    profileImageFilePath VARCHAR(255),
    BOD DATE,
    certificationFilePath VARCHAR(255),
    address TEXT,
    status VARCHAR(10) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    dateJoined TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registerID) REFERENCES registration(registerID)
);

-- Table 3: Instructor
CREATE TABLE instructor (
    instructorID SERIAL PRIMARY KEY,
    registerID INTEGER NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    nric VARCHAR(20),
    profileImageFilePath VARCHAR(255),
    BOD DATE,
    certificationFilePath VARCHAR(255),
    yearOfExperience INTEGER,
    address TEXT,
    status VARCHAR(10) NOT NULL DEFAULT 'inactive' CHECK (status IN ('active', 'inactive')),
    dateJoined TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewedBy INTEGER,
    reviewedAt TIMESTAMP,
    FOREIGN KEY (registerID) REFERENCES registration(registerID),
    FOREIGN KEY (reviewedBy) REFERENCES admin(adminID)
);

-- Table 4: Class
CREATE TABLE class (
    classID SERIAL PRIMARY KEY,
    className VARCHAR(100) NOT NULL,
    classType VARCHAR(100),
    classLevel VARCHAR(50),
    classDate DATE,
    classStartTime TIME,
    classEndTime TIME,
    noOfParticipant INTEGER,
    location VARCHAR(255),
    description TEXT,
    classStatus VARCHAR(10) DEFAULT 'active' CHECK (classStatus IN ('active', 'inactive')),
    qrcodeFilePath VARCHAR(255),
    adminID INTEGER,
    FOREIGN KEY (adminID) REFERENCES admin(adminID)
);

-- Table 5: Class Confirmation
CREATE TABLE class_confirmation (
    confirmID SERIAL PRIMARY KEY,
    classID INTEGER,
    instructorID INTEGER,
    action VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (action IN ('confirmed', 'pending', 'cancelled')),
    actionAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cancellationReason TEXT,
    cancelledAt TIMESTAMP,
    FOREIGN KEY (classID) REFERENCES class(classID) ON DELETE CASCADE,
    FOREIGN KEY (instructorID) REFERENCES instructor(instructorID) ON DELETE CASCADE
);

-- Table 6: Feedback
CREATE TABLE feedback (
    feedbackID SERIAL PRIMARY KEY,
    instructorID INTEGER,
    classID INTEGER,
    teachingSkill INTEGER CHECK (teachingSkill BETWEEN 1 AND 5),
    communication INTEGER CHECK (communication BETWEEN 1 AND 5),
    supportInteraction INTEGER CHECK (supportInteraction BETWEEN 1 AND 5),
    punctuality INTEGER CHECK (punctuality BETWEEN 1 AND 5),
    overallRating INTEGER CHECK (overallRating BETWEEN 1 AND 5),
    comments TEXT,
    feedbackDate DATE,
    submissionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructorID) REFERENCES instructor(instructorID) ON DELETE CASCADE,
    FOREIGN KEY (classID) REFERENCES class(classID) ON DELETE CASCADE
);

-- Table 7: Password Reset
CREATE TABLE password_reset (
    resetID SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    userRole VARCHAR(10) NOT NULL CHECK (userRole IN ('admin', 'instructor')),
    token VARCHAR(64) NOT NULL UNIQUE,
    expiryTime TIMESTAMP NOT NULL,
    used CHAR(1) NOT NULL DEFAULT 'N' CHECK (used IN ('Y', 'N')),
    createdTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
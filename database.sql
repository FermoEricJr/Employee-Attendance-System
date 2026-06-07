-- Create the database and select it
CREATE DATABASE IF NOT EXISTS EmAttendancedb;
USE EmAttendancedb;

-- =================================================================
-- 1. Lookup Tables (Independent Entities)
-- =================================================================

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE -- e.g., 'admin', 'hr', 'employee'
);

CREATE TABLE shifts (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_name VARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

CREATE TABLE leave_types (
    leave_type_id INT AUTO_INCREMENT PRIMARY KEY,
    leave_name VARCHAR(50) NOT NULL UNIQUE -- e.g., 'Sick', 'Vacation', 'Unpaid'
);

-- =================================================================
-- 2. The Core User Table
-- =================================================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    department_id INT,
    role_id INT,
    shift_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT,
    FOREIGN KEY (shift_id) REFERENCES shifts(shift_id) ON DELETE SET NULL
);

-- =================================================================
-- 3. The Transactional Tables
-- =================================================================

CREATE TABLE attendance_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    log_date DATE NOT NULL,
    clock_in DATETIME NOT NULL,
    clock_out DATETIME DEFAULT NULL,
    status ENUM('On Time', 'Late', 'Absent', 'Half Day') DEFAULT 'On Time',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE (user_id, log_date) -- Prevents a user from having two separate log records for the same day
);

CREATE TABLE leave_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    approval_status ENUM('Pending', 'Approved', 'Denied') DEFAULT 'Pending',
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id) ON DELETE RESTRICT
);
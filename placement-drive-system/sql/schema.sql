CREATE DATABASE IF NOT EXISTS placement_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE placement_db;
CREATE TABLE IF NOT EXISTS users (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, full_name VARCHAR(120) NOT NULL, email VARCHAR(190) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL, role ENUM('admin','student') NOT NULL DEFAULT 'student', is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, INDEX idx_users_role(role)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS students (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id BIGINT UNSIGNED NOT NULL UNIQUE,
 registration_number VARCHAR(40) NOT NULL UNIQUE, phone VARCHAR(25), department VARCHAR(80) NOT NULL,
 graduation_year SMALLINT UNSIGNED NOT NULL, cgpa DECIMAL(4,2) NOT NULL, active_backlogs TINYINT UNSIGNED NOT NULL DEFAULT 0,
 skills TEXT, resume_path VARCHAR(255), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_student_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
 INDEX idx_students_registration(registration_number), INDEX idx_students_department(department), INDEX idx_students_year(graduation_year)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS companies (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, company_name VARCHAR(150) NOT NULL, website VARCHAR(255), location VARCHAR(150),
 description TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_companies_active(is_active), INDEX idx_companies_name(company_name)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS placement_drives (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, company_id BIGINT UNSIGNED NOT NULL,
 job_title VARCHAR(150) NOT NULL, job_description TEXT, job_location VARCHAR(150), package_lpa DECIMAL(8,2) NOT NULL DEFAULT 0,
 min_cgpa DECIMAL(4,2) NOT NULL DEFAULT 0, max_active_backlogs TINYINT UNSIGNED NOT NULL DEFAULT 0,
 graduation_year SMALLINT UNSIGNED NOT NULL, application_deadline DATETIME NOT NULL, drive_date DATETIME,
 status ENUM('draft','published','closed') NOT NULL DEFAULT 'draft', created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_drive_company FOREIGN KEY(company_id) REFERENCES companies(id) ON DELETE RESTRICT,
 INDEX idx_drives_status_deadline(status,application_deadline), INDEX idx_drives_company(company_id), INDEX idx_drives_year(graduation_year)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS drive_departments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, drive_id BIGINT UNSIGNED NOT NULL, department VARCHAR(80) NOT NULL,
 CONSTRAINT fk_dept_drive FOREIGN KEY(drive_id) REFERENCES placement_drives(id) ON DELETE CASCADE,
 UNIQUE KEY uq_drive_department(drive_id,department), INDEX idx_drive_dept_department(department)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS applications (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, student_id BIGINT UNSIGNED NOT NULL, drive_id BIGINT UNSIGNED NOT NULL,
 status ENUM('applied','shortlisted','rejected','selected','on_hold') NOT NULL DEFAULT 'applied',
 applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_app_student FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE RESTRICT,
 CONSTRAINT fk_app_drive FOREIGN KEY(drive_id) REFERENCES placement_drives(id) ON DELETE RESTRICT,
 UNIQUE KEY uq_student_drive(student_id,drive_id), INDEX idx_app_status(status), INDEX idx_app_drive(drive_id), INDEX idx_app_student(student_id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS interviews (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, application_id BIGINT UNSIGNED NOT NULL, round_name VARCHAR(100) NOT NULL,
 scheduled_at DATETIME NOT NULL, interview_mode ENUM('online','in_person','phone') NOT NULL DEFAULT 'in_person',
 meeting_location VARCHAR(255), result ENUM('pending','passed','failed','on_hold') NOT NULL DEFAULT 'pending', remarks TEXT,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_interview_app FOREIGN KEY(application_id) REFERENCES applications(id) ON DELETE RESTRICT,
 INDEX idx_interview_app(application_id), INDEX idx_interview_schedule(scheduled_at)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS notifications (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id BIGINT UNSIGNED NOT NULL, message VARCHAR(500) NOT NULL,
 is_read BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_notification_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_notification_user_read(user_id,is_read)
) ENGINE=InnoDB;

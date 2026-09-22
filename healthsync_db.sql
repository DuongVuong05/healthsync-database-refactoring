CREATE DATABASE IF NOT EXISTS healthsync_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE healthsync_db;

DROP TABLE IF EXISTS Prescriptions;
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') 
        NOT NULL DEFAULT 'PENDING',
    deposit_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    penalty_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    cancel_reason VARCHAR(255) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
) ENGINE=InnoDB;

DELIMITER //
CREATE TRIGGER trg_check_prescription_before_insert
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT status INTO v_status 
    FROM Appointments 
    WHERE appointment_id = NEW.appointment_id;
    
    IF v_status IS NULL OR v_status != 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Chỉ được phép kê đơn thuốc cho lịch hẹn đã HOÀN THÀNH (COMPLETED).';
    END IF;
END //
DELIMITER ;

INSERT INTO Patients (full_name, phone) VALUES 
('Nguyễn Văn A', '0901234567'),
('Trần Thị B', '0918765432');

INSERT INTO Doctors (full_name, specialty) VALUES 
('BS. Lê Văn C', 'Nội khoa'),
('BS. Phạm Thị D', 'Nhi khoa');

-- Kịch bản 1: Hoàn thành khám
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-10-01 09:00:00', 'PENDING', 500000.00);
SET @app1_id = LAST_INSERT_ID();

UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = @app1_id;
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = @app1_id;

INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (@app1_id, '1. Paracetamol 500mg (20 viên) - Uống 2 lần/ngày\n2. Vitamin C 500mg (10 viên)');

-- Kịch bản 2: Hủy lịch & Phạt
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 2, '2026-10-02 14:00:00', 'PENDING', 300000.00);
SET @app2_id = LAST_INSERT_ID();

UPDATE Appointments SET status = 'CONFIRMED' WHERE appointment_id = @app2_id;
UPDATE Appointments SET status = 'CANCELLED',
    cancel_reason = 'Bận việc đột xuất không thể sắp xếp thời gian',
    penalty_fee = 150000.00
WHERE appointment_id = @app2_id;

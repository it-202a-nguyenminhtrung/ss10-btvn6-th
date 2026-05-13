CREATE DATABASE patient_db;
USE patient_db;

CREATE TABLE patients (
	id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    admission_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vitals_logs (
	id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id VARCHAR(5) NOT NULL,
    heart_rate INT CHECK(heart_rate > 0),
    blood_pressure VARCHAR(8) NOT NULL,
    record_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(patient_id) REFERENCES patients (id)
);

INSERT INTO patients (id, full_name, admission_time) VALUES 
('P0001', 'Nguyễn Văn A', '2023-10-25 08:30:00'),
('P0002', 'Trần Thị B', '2023-10-25 09:15:00'),
('P0003', 'Lê Minh C', '2023-10-26 14:00:00'),
('P0004', 'Lê Minh T', '2023-10-27 14:00:00');

INSERT INTO vitals_logs (patient_id, heart_rate, blood_pressure, record_time) VALUES 
-- Bệnh nhân P0001
('P0001', 75, '120/80', '2023-10-25 08:35:00'),
('P0001', 121, '122/82', '2023-10-25 12:00:00'),

-- Bệnh nhân P0002
('P0002', 110, '140/90', '2023-10-25 09:20:00'),
('P0002', 105, '135/88', '2023-10-25 15:00:00'),

-- Bệnh nhân P0003
('P0003', 49, '115/75', '2023-10-26 14:10:00');
-- Thao tác 2: Tạo composite index
CREATE INDEX idx_vitals_logs ON vitals_logs (patient_id, record_time);

-- Thao tác 3: Xây dựng dashboard hiển thị
-- Tạo VIEW để lấy ra bảng đầy đủ thông tin bệnh nhân kể cả dữ liệu sinh tồn của bệnh nha
CREATE VIEW ER_DASHBOARD_VIEW AS
SELECT p.id AS patient_id, p.full_name, p.admission_time, ifnull(vl.heart_rate, 'pending') as heart_rate, vl.blood_pressure ,vl.id AS vitals_logs_id,  
			CASE 
				WHEN vl.heart_rate > 120 OR vl.heart_rate < 50 THEN 'CRITICAL'
                ELSE 'STABLE'
			END AS Urgency_Level
FROM patients p
LEFT JOIN vitals_logs vl ON p.id = vl.patient_id
ORDER BY record_time DESC;

-- VIEW để lấy ra bảng có cơ chế lấy BẢN GHI MỚI NHẤT (THEO YÊU CẦU ĐỀ BÀI) !
CREATE VIEW ER_DASHBOARD_VIEW_Mechanism_TOP1 AS
SELECT p.id AS patient_id, p.full_name, p.admission_time, ifnull(vl.heart_rate, 'pending') as heart_rate, vl.blood_pressure ,vl.id AS vitals_logs_id,  
			CASE 
				WHEN vl.heart_rate > 120 OR vl.heart_rate < 50 THEN 'CRITICAL'
                ELSE 'STABLE'
			END AS Urgency_Level
FROM patients p
LEFT JOIN vitals_logs vl ON p.id = vl.patient_id
ORDER BY record_time DESC
LIMIT 1;

SELECT * FROM ER_DASHBOARD_VIEW;
SELECT * FROM ER_DASHBOARD_VIEW_Mechanism_TOP1;  

-- Thao tác 4: Kiểm tra tính bảo mật
INSERT INTO ER_DASHBOARD_VIEW (full_name) VALUES (NULL); 
-- Sẽ không thể thêm cũng như sửa được bởi vì bảng ER_DASHBOARD_VIEW lúc này đang được join bởi nhiều bảng khác nên gặp lỗi khi thêm hoặc sửa
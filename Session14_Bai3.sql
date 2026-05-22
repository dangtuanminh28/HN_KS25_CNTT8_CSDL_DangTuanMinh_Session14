DROP DATABASE IF EXISTS s14;
CREATE DATABASE s14;
USE s14;

CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE medical (
    med_id INT PRIMARY KEY AUTO_INCREMENT,
    med_name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT DEFAULT 0
);

CREATE TABLE medic_fee (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) DEFAULT 0,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

INSERT INTO patients (full_name) VALUES 
('Nguyen Van An'),
('Tran Thi Binh'),
('Le Hoang Cuong'),
('Pham Minh Duc'),
('Vu Thu Ha');

INSERT INTO medical (med_name, price, stock) VALUES
('Paracetamol', 10000, 50),
('Amoxicillin', 15000, 5),
('Panadol Extra', 5000, 100),
('Augmentin 1g', 25000, 2),
('Vitamin C', 2000, 200);

INSERT INTO medic_fee (patient_id, total_due) VALUES 
(1, 0),
(2, 150000),
(3, 0),
(4, 50000),
(5, 0);

DROP PROCEDURE IF EXISTS dispensing_medicine;
DELIMITER //
CREATE PROCEDURE dispensing_medicine (
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(18,2);

    START TRANSACTION;
    SELECT stock, price INTO v_stock, v_price FROM medical
    WHERE med_id = p_medicine_id;

    IF v_stock IS NULL THEN
        ROLLBACK;
        SET p_message = 'Lỗi: Mã thuốc không tồn tại trên hệ thống!';
        
    ELSEIF p_quantity <= 0 THEN
        ROLLBACK;
        SET p_message = 'Lỗi: Số lượng cấp phát phải lớn hơn 0!';

    ELSEIF v_stock < p_quantity THEN
        ROLLBACK;
        SET p_message = 'Lỗi: Số lượng tồn kho không đủ';

    ELSE
        UPDATE medical SET stock = stock - p_quantity
        WHERE med_id = p_medicine_id;

        UPDATE medic_fee SET total_due = total_due + (p_quantity * v_price)
        WHERE patient_id = p_patient_id;

        COMMIT;
        SET p_message = 'Đã cấp phát thành công';
    END IF;
END //
DELIMITER ;

SET @message = '';

CALL dispensing_medicine(1, 1, 5, @message);

SELECT @message AS result; 
SELECT med_id, med_name, price, stock FROM medical WHERE med_id = 1;
SELECT patient_id, total_due FROM medic_fee WHERE patient_id = 1;

CALL dispensing_medicine(1, 2, 10, @message);
SELECT @message AS result; 
SELECT med_id, med_name, price, stock FROM medical WHERE med_id = 2;
SELECT patient_id, total_due FROM medic_fee WHERE patient_id = 1;
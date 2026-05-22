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

/*
Xác định dữ liệu Đầu vào và Đầu ra
* Tham số Đầu vào (IN):
p_patient_id INT: Mã bệnh nhân nhận thuốc
p_medicine_id INT): Mã thuốc trong kho
p_quantity INT: Số lượng thuốc nhân viên yêu cầu cấp phát

* Tham số Đầu ra (OUT):
p_message VARCHAR(255): Chuỗi thông báo trạng thái kết quả xử lý
Giải pháp:
- Sử dụng kết hợp các tham số loại IN để nhận dữ liệu thực thi và một tham số loại OUT để thu hồi thông báo trạng thái

-  Các bước thực hiện
1. Khởi đầu dùng START TRANSACTION
2. Truy vấn số lượng tồn kho (stock) và đơn giá (price) của thuốc từ bảng medical
3. Điều kiện ko hợp lệ:
- Nếu mã thuốc không tồn tại hoặc số lượng nhập vào bé hơn hoặc = 0 dùng ROLLBACK và thông báo lỗi
- Nếu số lượng yêu cầu p_quantity lớn hơn stock thực tế dùng ROLLBACK, xóa toàn bộ dữ liệu trước đó để tránh âm kho,
thêm thông báo lỗi số lượng kho
4. Điều kiện hợp lệ:
- Giảm số lượng tồn kho tương ứng từ bảng medical
- Tính tổng tiền (p_quantity * price) rồi cộng total_due của bệnh nhân trong bảng medic_fee
5. Dùng lệnh COMMIT để lưu dữ liệu và gán thông báo đã thành công
*/
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
DROP DATABASE IF EXISTS RikkeiClinicDB;
CREATE DATABASE RikkeiClinicDB;
USE RikkeiClinicDB;

-- PHẦN 1: KHỞI TẠO CẤU TRÚC BẢNG 

-- 1. Bảng Bệnh nhân (Patients)
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    date_of_birth DATE
);

-- 2. Bảng Nhân sự / Bác sĩ (Employees)
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) NOT NULL
);

-- 3. Bảng Khoa (Departments)
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

-- 4. Bảng Giường bệnh (Beds)
CREATE TABLE Beds (
    bed_id INT PRIMARY KEY,
    dept_id INT NOT NULL,
    patient_id INT DEFAULT NULL, -- NULL nghĩa là giường trống
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 5. Bảng Lịch khám (Appointments)
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Completed', 'Cancelled'
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Employees(employee_id)
);

-- 6. Bảng Kho Vật tư Y tế (Inventory)
CREATE TABLE Inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
);

-- 7. Bảng Kho Thuốc (Medicines)
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 8. Bảng Công nợ Bệnh nhân (Patient_Invoices)
CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 9. Bảng Sản phẩm (Products)
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 10. Bảng Dịch vụ khám (Services) 
CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL
);

-- 11. Bảng Ví điện tử (Wallets) 
CREATE TABLE Wallets (
    patient_id INT PRIMARY KEY,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active', -- 'Active', 'Inactive'
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 12. Bảng Lịch sử sử dụng dịch vụ (Service_Usages) 
CREATE TABLE Service_Usages (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    service_id INT NOT NULL,
    actual_price DECIMAL(18,2) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- PHẦN 2: CHÈN DỮ LIỆU MẪU (TEST CASES)
-- Chèn Bệnh nhân
INSERT INTO Patients (patient_id, full_name, phone, date_of_birth) VALUES
(1, 'Nguyen Van An', '0901111222', '1990-05-15'),
(2, 'Tran Thi Binh', '0912222333', '1985-08-20'),
(3, 'Le Hoang Cuong', '0923333444', '2000-12-01');

-- Chèn Nhân sự 
INSERT INTO Employees (employee_id, full_name, position, salary) VALUES
(101, 'Dr. Hoang Minh', 'Doctor', 20000.00),
(102, 'Dr. Lan Anh', 'Doctor', 25000.00),
(103, 'Nurse Thu Ha', 'Nurse', 12000.00);

-- Chèn Khoa
INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'Khoa Ngoai'),
(2, 'Khoa Noi'),
(3, 'Khoa ICU');

-- Chèn Giường bệnh
INSERT INTO Beds (bed_id, dept_id, patient_id) VALUES
(101, 1, 1),    -- Bệnh nhân 1 đang nằm giường 101 Khoa Ngoại
(201, 2, NULL), -- Giường 201 Khoa Nội đang trống
(301, 3, 2);    -- Bệnh nhân 2 đang nằm ICU

-- Chèn Lịch khám 
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status) VALUES
(104, 1, 101, '2026-06-10 08:30:00', 'Pending'),
(105, 2, 102, '2026-05-01 09:00:00', 'Completed'),
(106, 3, 101, '2026-05-02 10:00:00', 'Cancelled');

-- Chèn Vật tư 
INSERT INTO Inventory (item_id, item_name, stock_quantity) VALUES
(10, 'Khau trang y te N95', 1000),
(11, 'Gang tay vo trung', 500),
(12, 'Dung dich sat khuan', 200);

-- Chèn Thuốc
INSERT INTO Medicines (medicine_id, name, price, stock) VALUES
(1, 'Amoxicillin 500mg', 15000, 100),  -- Tồn kho nhiều
(2, 'Panadol Extra', 5000, 5);         -- Tồn kho ít

-- Chèn Công nợ Bệnh nhân
INSERT INTO Patient_Invoices (patient_id, total_due) VALUES
(1, 1500000.00), -- Đã sửa: Nợ 1.5tr để test bài Giải phóng giường bệnh
(2, 0),
(3, 0);

-- Chèn Sản phẩm E-commerce 
INSERT INTO Products (name, price, stock) VALUES
('May do huyet ap Omron', 850000.00, 20),
('May do duong huyet', 450000.00, 15);

-- Chèn Dịch vụ
INSERT INTO Services (service_id, name, price) VALUES
(1, 'Sieu am o bung', 200000.00),
(2, 'Xet nghiem mau', 150000.00),
(3, 'Chup X-Quang', 250000.00);

-- Chèn Ví điện tử
INSERT INTO Wallets (patient_id, balance, status) VALUES
(1, 500000.00, 'Active'),    -- Test Case 1: Đủ tiền thanh toán
(2, 50000.00, 'Active'),     -- Test Case 3: Cháy ví (Chỉ có 50k, không đủ khám 200k)
(3, 1000000.00, 'Inactive'); -- Test Case 2: Nhiều tiền nhưng thẻ bị khóa


/*
Phần A: Phân tích 
Input:
- Tham số IN:
p_patient_id INT, p_product_id INT, p_quantity INT (thêm p để tránh trùng bảng)
- Tham số OUT:
p_status_message VARCHAR(100) (trả kết quả thông báo)

Thiết kế luồng xử lý dữ liệu
- Các biến DECLARE
v_stock INT					(Lưu số lượng kho)
v_price DECIMAL(10,2)		(Lưu giá sản phẩm)
v_total DECIMAL(10,2)		(Lưu tổng tiền thanh toán)
v_balance DECIMAL(10,2) 	(Lưu số dư ví của bệnh nhân)
v_status VARCHAR(20) 		(Lưu trạng thái)
- Vị trí đặt các lệnh
START TRANSACTION			(Đặt sau phần DECLARE)
ROLLBACK;					(Đặt trước lệnh SIGNAL)
COMMIT;						(Đặt ở cuối, ngay sau khi các lệnh đều thỏa mãn)
*/

-- Phần B
DROP PROCEDURE IF EXISTS ProcessEquipmentPurchase;
DELIMITER //
CREATE PROCEDURE ProcessEquipmentPurchase (
    IN p_patient_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_balance DECIMAL(10,2);
    DECLARE v_status VARCHAR(20);
    
    START TRANSACTION;
    
    SELECT stock, price INTO v_stock, v_price 
    FROM products WHERE product_id = p_product_id;
    
    SELECT balance, status INTO v_balance, v_status 
    FROM wallets WHERE patient_id = p_patient_id;
    
    -- Kiểm tra kho hàng
    IF v_stock < p_quantity THEN
        ROLLBACK;
        SELECT 'Thất bại: Kho không đủ sản phẩm' AS message;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thất bại: Kho không đủ sản phẩm';
    END IF;
    
    -- Kiểm tra tài khoản
    IF v_status = 'Inactive' THEN
        ROLLBACK;
        SELECT 'Thất bại: Ví đang bị khóa' AS message;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thất bại: Ví đang bị khóa';
    END IF;
    
    -- Tính toán tổng tiền
    SET v_total = p_quantity * v_price;
    
    -- Kiểm tra số dư
    IF v_balance < v_total THEN
        ROLLBACK;
        SELECT 'Thất bại: Số dư ví không đủ' AS message;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thất bại: Số dư ví không đủ';
    END IF;
    
    -- Đủ điều kiện thanh toán
    UPDATE products SET stock = stock - p_quantity WHERE product_id = p_product_id;
    UPDATE wallets SET balance = balance - v_total WHERE patient_id = p_patient_id;
    
    COMMIT;
    SELECT 'Thành công: Đã xử lý đơn hàng' AS message;
    
END //
DELIMITER ;

-- Test 1: Mua hàng hợp lệ (Thành công)
CALL ProcessEquipmentPurchase(1, 10, 2);
-- Test 2: Lỗi Out of stock (Hết hàng)
CALL ProcessEquipmentPurchase(1, 10, 10);
-- Test 3: Lỗi Insufficient funds (Không đủ tiền)
CALL ProcessEquipmentPurchase(1, 10, 3);
-- Test 4: Lỗi Locked Account (Tài khoản bị khóa)
CALL ProcessEquipmentPurchase(2, 10, 1);
-- ============================================================
-- Project: Raast Integrated Digital Wallet and Transaction Monitoring System
-- Course: CS2013 Introduction to Database Systems
-- DBMS: MySQL Workbench / XAMPP
-- ============================================================

DROP DATABASE IF EXISTS raast_wallet_system;
CREATE DATABASE raast_wallet_system;
USE raast_wallet_system;

-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    cnic VARCHAR(15) NOT NULL UNIQUE,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    address VARCHAR(255),
    kyc_status ENUM('Pending', 'Verified', 'Rejected') DEFAULT 'Pending',
    account_status ENUM('Active', 'Blocked', 'Inactive') DEFAULT 'Active',
    registration_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE banks (
    bank_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_name VARCHAR(100) NOT NULL,
    branch_code VARCHAR(20),
    city VARCHAR(50)
);

CREATE TABLE bank_accounts (
    bank_account_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    bank_id INT NOT NULL,
    iban VARCHAR(34) NOT NULL UNIQUE,
    account_title VARCHAR(100) NOT NULL,
    linked_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (bank_id) REFERENCES banks(bank_id)
);

CREATE TABLE wallets (
    wallet_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    wallet_number VARCHAR(20) NOT NULL UNIQUE,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    wallet_type ENUM('Basic', 'Premium', 'Merchant') DEFAULT 'Basic',
    wallet_status ENUM('Active', 'Blocked', 'Inactive') DEFAULT 'Active',
    created_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (balance >= 0)
);

CREATE TABLE merchants (
    merchant_id INT PRIMARY KEY AUTO_INCREMENT,
    merchant_name VARCHAR(100) NOT NULL,
    category VARCHAR(60),
    contact_number VARCHAR(15),
    city VARCHAR(50),
    status ENUM('Active', 'Inactive') DEFAULT 'Active'
);

CREATE TABLE transaction_types (
    transaction_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_wallet_id INT,
    receiver_wallet_id INT,
    merchant_id INT,
    transaction_type_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_status ENUM('Successful', 'Failed', 'Pending') DEFAULT 'Pending',
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(255),
    FOREIGN KEY (sender_wallet_id) REFERENCES wallets(wallet_id),
    FOREIGN KEY (receiver_wallet_id) REFERENCES wallets(wallet_id),
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id),
    FOREIGN KEY (transaction_type_id) REFERENCES transaction_types(transaction_type_id),
    CHECK (amount > 0)
);

CREATE TABLE fraud_alerts (
    fraud_alert_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    wallet_id INT,
    reason VARCHAR(255) NOT NULL,
    severity ENUM('Low', 'Medium', 'High') DEFAULT 'Low',
    alert_status ENUM('Open', 'Investigating', 'Closed') DEFAULT 'Open',
    alert_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id)
);

-- ============================================================
-- 2. INDEXING
-- ============================================================

CREATE INDEX idx_users_cnic ON users(cnic);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_wallet_number ON wallets(wallet_number);
CREATE INDEX idx_transaction_date ON transactions(transaction_date);
CREATE INDEX idx_transaction_status ON transactions(transaction_status);
CREATE INDEX idx_fraud_severity ON fraud_alerts(severity);

-- ============================================================
-- 3. SAMPLE DATA
-- ============================================================

INSERT INTO users (full_name, cnic, phone_number, email, city, address, kyc_status, account_status)
VALUES
('Ali Khan', '42101-1234567-1', '03001234567', 'ali.khan@email.com', 'Karachi', 'Gulshan e Iqbal, Karachi', 'Verified', 'Active'),
('Sara Ahmed', '42101-7654321-2', '03007654321', 'sara.ahmed@email.com', 'Lahore', 'DHA Phase 5, Lahore', 'Verified', 'Active'),
('Hamza Malik', '61101-2222222-3', '03112222222', 'hamza.malik@email.com', 'Islamabad', 'G 11, Islamabad', 'Verified', 'Active'),
('Ayesha Noor', '42201-3333333-4', '03213333333', 'ayesha.noor@email.com', 'Rawalpindi', 'Satellite Town, Rawalpindi', 'Pending', 'Active'),
('Usman Raza', '42301-4444444-5', '03334444444', 'usman.raza@email.com', 'Peshawar', 'University Road, Peshawar', 'Verified', 'Active'),
('Zainab Tariq', '35202-5555555-6', '03455555555', 'zainab.tariq@email.com', 'Lahore', 'Model Town, Lahore', 'Verified', 'Active'),
('Bilal Hussain', '37405-6666666-7', '03066666666', 'bilal.hussain@email.com', 'Islamabad', 'F 10, Islamabad', 'Verified', 'Active'),
('Mariam Iqbal', '42501-7777777-8', '03177777777', 'mariam.iqbal@email.com', 'Karachi', 'Clifton, Karachi', 'Rejected', 'Inactive'),
('Danish Sheikh', '42301-8888888-9', '03288888888', 'danish.sheikh@email.com', 'Multan', 'Cantt, Multan', 'Verified', 'Active'),
('Hina Farooq', '33101-9999999-0', '03399999999', 'hina.farooq@email.com', 'Faisalabad', 'Madina Town, Faisalabad', 'Verified', 'Active');

INSERT INTO banks (bank_name, branch_code, city)
VALUES
('HBL', 'HBL001', 'Karachi'),
('Meezan Bank', 'MZN002', 'Lahore'),
('UBL', 'UBL003', 'Islamabad'),
('Bank Alfalah', 'BAF004', 'Rawalpindi'),
('MCB Bank', 'MCB005', 'Faisalabad');

INSERT INTO bank_accounts (user_id, bank_id, iban, account_title)
VALUES
(1, 1, 'PK36HABB0000001123456702', 'Ali Khan'),
(2, 2, 'PK45MEZN0000001765432109', 'Sara Ahmed'),
(3, 3, 'PK22UNIL0000001222222203', 'Hamza Malik'),
(5, 4, 'PK11ALFH0000001444444407', 'Usman Raza'),
(6, 2, 'PK54MEZN0000001555555508', 'Zainab Tariq'),
(7, 3, 'PK99UNIL0000001666666604', 'Bilal Hussain'),
(9, 5, 'PK33MUCB0000001888888801', 'Danish Sheikh'),
(10, 5, 'PK21MUCB0000001999999902', 'Hina Farooq');

INSERT INTO wallets (user_id, wallet_number, balance, wallet_type, wallet_status)
VALUES
(1, 'WLT1001', 150000.00, 'Premium', 'Active'),
(2, 'WLT1002', 85000.00, 'Basic', 'Active'),
(3, 'WLT1003', 45000.00, 'Basic', 'Active'),
(4, 'WLT1004', 10000.00, 'Basic', 'Active'),
(5, 'WLT1005', 250000.00, 'Premium', 'Active'),
(6, 'WLT1006', 67000.00, 'Basic', 'Active'),
(7, 'WLT1007', 92000.00, 'Premium', 'Active'),
(8, 'WLT1008', 5000.00, 'Basic', 'Inactive'),
(9, 'WLT1009', 30500.00, 'Basic', 'Active'),
(10, 'WLT1010', 120000.00, 'Premium', 'Active');

INSERT INTO merchants (merchant_name, category, contact_number, city, status)
VALUES
('Daraz Store', 'E-Commerce', '0211111111', 'Karachi', 'Active'),
('FoodPanda Partner', 'Food Delivery', '0212222222', 'Lahore', 'Active'),
('Metro Cash and Carry', 'Retail', '0213333333', 'Islamabad', 'Active'),
('Careem Pay Merchant', 'Transport', '0214444444', 'Karachi', 'Active'),
('Imtiaz Super Market', 'Retail', '0215555555', 'Karachi', 'Active');

INSERT INTO transaction_types (type_name, description)
VALUES
('Wallet Transfer', 'Money transfer between two wallets'),
('Merchant Payment', 'Payment made to a registered merchant'),
('Bank Transfer', 'Transfer between wallet and linked bank account'),
('Cash In', 'Money added into wallet'),
('Cash Out', 'Money withdrawn from wallet');

-- ============================================================
-- 4. TRIGGER FOR FRAUD ALERT FLAGS
-- This trigger automatically creates a fraud alert when:
-- amount is greater than 100000 OR transaction status is Failed.
-- ============================================================

DELIMITER $$
CREATE TRIGGER trg_flag_suspicious_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.amount > 100000 THEN
        INSERT INTO fraud_alerts (transaction_id, wallet_id, reason, severity, alert_status)
        VALUES (NEW.transaction_id, NEW.sender_wallet_id, 'High value transaction above Rs. 100000', 'High', 'Open');
    END IF;

    IF NEW.transaction_status = 'Failed' THEN
        INSERT INTO fraud_alerts (transaction_id, wallet_id, reason, severity, alert_status)
        VALUES (NEW.transaction_id, NEW.sender_wallet_id, 'Failed transaction attempt detected', 'Medium', 'Open');
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- 5. INSERT TRANSACTIONS
-- Fraud trigger will run automatically on these records.
-- ============================================================

INSERT INTO transactions (sender_wallet_id, receiver_wallet_id, merchant_id, transaction_type_id, amount, transaction_status, transaction_date, remarks)
VALUES
(1, 2, NULL, 1, 5000.00, 'Successful', '2026-04-01 10:20:00', 'Ali sent money to Sara'),
(2, 3, NULL, 1, 12000.00, 'Successful', '2026-04-01 11:00:00', 'Sara sent money to Hamza'),
(1, NULL, 1, 2, 3000.00, 'Successful', '2026-04-02 14:30:00', 'Ali paid Daraz Store'),
(5, 1, NULL, 1, 125000.00, 'Successful', '2026-04-03 09:15:00', 'Large transfer from Usman to Ali'),
(3, NULL, 2, 2, 2500.00, 'Failed', '2026-04-03 16:45:00', 'Payment failed due to network issue'),
(4, 2, NULL, 1, 8000.00, 'Successful', '2026-04-04 12:20:00', 'Ayesha sent money to Sara'),
(7, NULL, 3, 2, 45000.00, 'Successful', '2026-04-05 13:10:00', 'Bilal paid Metro'),
(10, 6, NULL, 1, 150000.00, 'Successful', '2026-04-06 15:35:00', 'Hina sent large amount to Zainab'),
(9, NULL, 5, 2, 1500.00, 'Successful', '2026-04-07 18:25:00', 'Danish paid Imtiaz'),
(6, 7, NULL, 1, 22000.00, 'Successful', '2026-04-08 10:50:00', 'Zainab sent money to Bilal'),
(2, NULL, 4, 2, 1800.00, 'Failed', '2026-04-08 21:05:00', 'Careem Pay failed'),
(1, 9, NULL, 1, 9500.00, 'Successful', '2026-04-09 08:45:00', 'Ali sent money to Danish'),
(5, NULL, 1, 2, 6500.00, 'Successful', '2026-04-10 19:40:00', 'Usman paid Daraz'),
(7, 10, NULL, 1, 25000.00, 'Successful', '2026-04-11 17:00:00', 'Bilal sent money to Hina'),
(10, NULL, 2, 2, 4000.00, 'Successful', '2026-04-12 20:30:00', 'Hina paid FoodPanda');

-- ============================================================
-- 6. VIEW FOR REPORTING
-- ============================================================

CREATE VIEW v_transaction_summary AS
SELECT
    t.transaction_id,
    su.full_name AS sender_name,
    sw.wallet_number AS sender_wallet,
    ru.full_name AS receiver_name,
    rw.wallet_number AS receiver_wallet,
    m.merchant_name,
    tt.type_name AS transaction_type,
    t.amount,
    t.transaction_status,
    t.transaction_date,
    t.remarks
FROM transactions t
LEFT JOIN wallets sw ON t.sender_wallet_id = sw.wallet_id
LEFT JOIN users su ON sw.user_id = su.user_id
LEFT JOIN wallets rw ON t.receiver_wallet_id = rw.wallet_id
LEFT JOIN users ru ON rw.user_id = ru.user_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id;

CREATE VIEW v_fraud_report AS
SELECT
    fa.fraud_alert_id,
    u.full_name,
    w.wallet_number,
    t.amount,
    t.transaction_status,
    fa.reason,
    fa.severity,
    fa.alert_status,
    fa.alert_date
FROM fraud_alerts fa
JOIN transactions t ON fa.transaction_id = t.transaction_id
LEFT JOIN wallets w ON fa.wallet_id = w.wallet_id
LEFT JOIN users u ON w.user_id = u.user_id;

-- ============================================================
-- 7. REQUIRED QUERIES FOR REPORT / VIVA
-- ============================================================

-- Query 1: Show all users with wallet details
SELECT u.user_id, u.full_name, u.cnic, u.phone_number, w.wallet_number, w.balance, w.wallet_type, w.wallet_status
FROM users u
JOIN wallets w ON u.user_id = w.user_id;

-- Query 2: Show complete transaction summary using joins
SELECT * FROM v_transaction_summary;

-- Query 3: Show failed transactions
SELECT transaction_id, sender_wallet_id, amount, transaction_date, remarks
FROM transactions
WHERE transaction_status = 'Failed';

-- Query 4: Show suspicious high value transactions above Rs. 100000
SELECT transaction_id, sender_wallet_id, amount, transaction_status, transaction_date
FROM transactions
WHERE amount > 100000;

-- Query 5: Monthly transaction volume using GROUP BY
SELECT
    YEAR(transaction_date) AS transaction_year,
    MONTH(transaction_date) AS transaction_month,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY YEAR(transaction_date), MONTH(transaction_date);

-- Query 6: Merchant wise total payments received
SELECT m.merchant_name, COUNT(t.transaction_id) AS total_payments, SUM(t.amount) AS total_received
FROM merchants m
JOIN transactions t ON m.merchant_id = t.merchant_id
WHERE t.transaction_status = 'Successful'
GROUP BY m.merchant_name;

-- Query 7: Users who made transactions greater than average transaction amount
SELECT u.full_name, w.wallet_number, t.amount
FROM users u
JOIN wallets w ON u.user_id = w.user_id
JOIN transactions t ON w.wallet_id = t.sender_wallet_id
WHERE t.amount > (SELECT AVG(amount) FROM transactions);

-- Query 8: Wallets with balance below Rs. 50000
SELECT u.full_name, w.wallet_number, w.balance
FROM users u
JOIN wallets w ON u.user_id = w.user_id
WHERE w.balance < 50000;

-- Query 9: Fraud alert report

CREATE VIEW v_fraud_report AS
SELECT 
    f.fraud_alert_id,
    t.transaction_id,
    u.full_name,
    w.wallet_number,
    t.amount,
    f.reason,
    f.severity,
    f.alert_date
FROM fraud_alerts f
JOIN transactions t ON f.transaction_id = t.transaction_id
JOIN wallets w ON t.sender_wallet_id = w.wallet_id
JOIN users u ON w.user_id = u.user_id;

SELECT * FROM v_fraud_report;

-- Query 10: Count transactions by status
SELECT transaction_status, COUNT(*) AS total_transactions
FROM transactions
GROUP BY transaction_status;

-- ============================================================
-- 8. TRANSACTION EXAMPLE FOR ACID CONCEPT
-- This example transfers Rs. 2000 from wallet 1 to wallet 2.
-- Run manually during demo.
-- ============================================================

START TRANSACTION;

UPDATE wallets
SET balance = balance - 2000
WHERE wallet_id = 1 AND balance >= 2000;

UPDATE wallets
SET balance = balance + 2000
WHERE wallet_id = 2;

INSERT INTO transactions (sender_wallet_id, receiver_wallet_id, transaction_type_id, amount, transaction_status, remarks)
VALUES (1, 2, 1, 2000, 'Successful', 'ACID transaction demo transfer');

COMMIT;

-- To undo before COMMIT, use ROLLBACK instead of COMMIT.

-- ============================================================
-- END OF PROJECT SQL FILE
-- ============================================================

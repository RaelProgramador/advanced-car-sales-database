-- ==========================================
-- 1. DATABASE SCHEMA CREATION (DDL)
-- ==========================================

CREATE TABLE Users (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Phone VARCHAR(15),
    Address TEXT NOT NULL,
    User_Type ENUM('Seller', 'Buyer') NOT NULL,
    CONSTRAINT UQ_Email UNIQUE (Email)
);

CREATE TABLE Buyers (
    Buyer_ID INT PRIMARY KEY,
    Purchase_History JSON,
    FOREIGN KEY (Buyer_ID) REFERENCES Users(User_ID)
);

CREATE TABLE Sellers (
    Seller_ID INT PRIMARY KEY,
    Company_Name VARCHAR(100),
    FOREIGN KEY (Seller_ID) REFERENCES Users(User_ID)
);

CREATE TABLE Vehicle (
    Vehicle_ID INT AUTO_INCREMENT PRIMARY KEY,
    Make VARCHAR(20) NOT NULL,
    Model VARCHAR(20) NOT NULL,
    Year_Of_Manufacture TINYINT NOT NULL,
    Mileage INT,
    Car_condition ENUM('New', 'Used', 'Damaged') NOT NULL,
    Price DECIMAL(10,2),
    Fuel_Type ENUM('Petrol', 'Diesel', 'Hybrid') NOT NULL,
    Transmission ENUM('Automatic', 'Manual') NOT NULL,
    Seller_ID INT NOT NULL,
    FOREIGN KEY (Seller_ID) REFERENCES Sellers(Seller_ID)
);

-- Schema Runtime Alteration Fix
ALTER TABLE Vehicle MODIFY Year_Of_Manufacture YEAR NOT NULL;

CREATE TABLE `Order` (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Buyer_ID INT NOT NULL,
    Vehicle_ID INT NOT NULL,
    Order_Date DATETIME NOT NULL,
    Payment_Status ENUM('Paid', 'Pending', 'Failed') NOT NULL,
    ShippingStatus ENUM('Dispatched', 'In Transit', 'Delivered') NOT NULL DEFAULT 'Dispatched',
    Total_Amount INT NOT NULL,
    FOREIGN KEY (Buyer_ID) REFERENCES Buyers(Buyer_ID),
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID)
);

CREATE TABLE Shipping (
    Shipping_ID INT AUTO_INCREMENT PRIMARY KEY,
    Estimated_Delivery_Date DATETIME,
    Shipping_Address VARCHAR(100),
    Order_ID INT NOT NULL,
    Carrier_Name VARCHAR(40),
    FOREIGN KEY (Order_ID) REFERENCES `Order`(Order_ID)
);

CREATE TABLE Sales_Reports (
    Report_ID INT AUTO_INCREMENT PRIMARY KEY,
    Report_Date DATETIME NOT NULL,
    Total_Vehicles INT NOT NULL,
    Vehicles_Sold INT NOT NULL,
    Revenue_Generated DECIMAL(15,2)
);

-- ==========================================
-- 2. PERFORMANCE OPTIMIZATION INDEX
-- ==========================================
CREATE INDEX idx_email ON Users(Email);

-- ==========================================
-- 3. DATABASE VIEWS
-- ==========================================

-- View 1: Top Selling Vehicles
CREATE VIEW View_TopSellingVehicles AS
SELECT 
    V.Make,
    V.Model,
    COUNT(O.Order_ID) AS Vehicles_Sold,
    SUM(O.Total_Amount) AS Total_Revenue
FROM 
    Vehicle V
JOIN `Order` O ON V.Vehicle_ID = O.Vehicle_ID
GROUP BY 
    V.Make, V.Model
ORDER BY 
    Vehicles_Sold DESC;

-- View 2: Recent Orders Tracking Dashboard
CREATE VIEW View_RecentOrdersWithShipping AS
SELECT 
    O.Order_ID,
    CONCAT(U.First_Name, ' ', U.Last_Name) AS Buyer_Name,
    O.Order_Date,
    O.Payment_Status,
    O.ShippingStatus,
    S.Estimated_Delivery_Date,
    S.Shipping_Address,
    V.Make,
    V.Model
FROM 
    `Order` O
JOIN Users U ON O.Buyer_ID = U.User_ID
JOIN Shipping S ON O.Order_ID = S.Order_ID
JOIN Vehicle V ON O.Vehicle_ID = V.Vehicle_ID
ORDER BY 
    O.Order_Date DESC
LIMIT 10;

-- ==========================================
-- 4. STORED PROCEDURES
-- ==========================================

DELIMITER $$
CREATE PROCEDURE GetBuyerOrderHistory(IN input_buyer_id INT)
BEGIN
    SELECT 
        O.Order_ID,
        O.Order_Date,
        O.Total_Amount,
        O.Payment_Status,
        V.Make,
        V.Model,
        S.Estimated_Delivery_Date
    FROM `Order` O
    JOIN Vehicle V ON O.Vehicle_ID = V.Vehicle_ID
    LEFT JOIN Shipping S ON O.Order_ID = S.Order_ID
    WHERE O.Buyer_ID = input_buyer_id
    ORDER BY O.Order_Date DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GenerateMonthlySalesReport()
BEGIN
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS Sale_Month,
        COUNT(Order_ID) AS Total_Orders,
        SUM(Total_Amount) AS Monthly_Revenue
    FROM `Order`
    GROUP BY Sale_Month
    ORDER BY Sale_Month DESC;
END $$
DELIMITER ;

-- ==========================================
-- 5. AUTOMATION TRIGGERS
-- ==========================================

DELIMITER $$
CREATE TRIGGER trg_AfterNewOrder
AFTER INSERT ON `Order`
FOR EACH ROW
BEGIN
    DECLARE currentMonth DATE;
    SET currentMonth = DATE_FORMAT(NEW.Order_Date, '%Y-%m-01');
 
    IF EXISTS (
        SELECT 1 FROM Sales_Reports 
        WHERE Report_Date = currentMonth
    ) THEN
        UPDATE Sales_Reports
        SET 
            Total_Vehicles = Total_Vehicles + 1,
            Vehicles_Sold = Vehicles_Sold + 1,
            Revenue_Generated = Revenue_Generated + NEW.Total_Amount
        WHERE Report_Date = currentMonth;
    ELSE
        INSERT INTO Sales_Reports (Report_Date, Total_Vehicles, Vehicles_Sold, Revenue_Generated)
        VALUES (currentMonth, 1, 1, NEW.Total_Amount);
    END IF;
END $$
DELIMITER ;

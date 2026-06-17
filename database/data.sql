-- ==========================================
-- POPULATING DATABASE PRODUCTION DATA (DML)
-- ==========================================

INSERT INTO Users (First_Name, Last_Name, Email, Phone, Address, User_Type) VALUES
('Rayssa', 'Castro', 'rayssa-castro@example.com', '07123456789', '123 Park Lane, London', 'Buyer'),
('Joao', 'Gabriel', 'joao.gabriel@example.com', '07234567890', '456 Elm Street, Manchester', 'Seller'),
('Zoe', 'Izidoro', 'zoe-izidoro@example.com', '07345678901', '789 Oak Avenue, Birmingham', 'Buyer'),
('Louise', 'Camara', 'louise.camara@example.com', '07456789012', '321 Maple Road, Bristol', 'Seller');

INSERT INTO Buyers (Buyer_ID, Purchase_History) VALUES
(1, JSON_ARRAY('Order_101', 'Order_102')),
(3, JSON_ARRAY('Order_103'));

INSERT INTO Sellers (Seller_ID, Company_Name) VALUES
(2, 'Joao’s Auto Mart'),
(4, 'Louise Car Sales');

INSERT INTO Vehicle (Make, Model, Year_Of_Manufacture, Mileage, Car_condition, Price, Fuel_Type, Transmission, Seller_ID) VALUES
('Ford', 'Fiesta', 2016, 55000, 'Used', 5200.00, 'Petrol', 'Manual', 2),
('BMW', '3 Series', 2019, 34000, 'Used', 14900.00, 'Diesel', 'Automatic', 4),
('Toyota', 'Yaris', 2018, 41000, 'Used', 8000.00, 'Hybrid', 'Automatic', 2),
('Vauxhall', 'Corsa', 2015, 67000, 'Used', 4000.00, 'Petrol', 'Manual', 4);

INSERT INTO `Order` (Buyer_ID, Vehicle_ID, Order_Date, Payment_Status, ShippingStatus, Total_Amount) VALUES
(1, 1, '2025-05-03', 'Paid', 'Delivered', 5200),
(3, 3, '2025-05-08', 'Pending', 'In Transit', 8000),
(1, 2, '2025-04-29', 'Paid', 'Dispatched', 14900);

INSERT INTO Shipping (Estimated_Delivery_Date, Shipping_Address, Order_ID, Carrier_Name) VALUES
('2025-05-30', '123 Park Lane, London', 1, 'DHL'),
('2025-05-22', '789 Oak Avenue, Birmingham', 2, 'FedEx'),
('2025-05-20', '123 Park Lane, London', 3, 'Royal Mail');

INSERT INTO Sales_Reports (Report_Date, Total_Vehicles, Vehicles_Sold, Revenue_Generated) VALUES
('2025-03-30', 100, 45, 215000.00),
('2025-02-28', 85, 30, 165000.00),
('2025-01-30', 70, 25, 128000.00);

-- ==========================================
-- AUTOMATION TRIGGER VERIFICATION RUN
-- ==========================================

-- This insert will automatically fire 'trg_AfterNewOrder' and create/update 'Sales_Reports'
INSERT INTO `Order` (Buyer_ID, Vehicle_ID, Order_Date, Payment_Status, ShippingStatus, Total_Amount)
VALUES (1, 4, '2025-05-12', 'Paid', 'Dispatched', 7300);

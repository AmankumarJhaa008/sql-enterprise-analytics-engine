-- =====================================================================
-- Project Name: Advanced E-Commerce & Supply Chain Analytics Engine
-- Description: Inserting sample mock data for testing and analytics
-- =====================================================================

-- 1. Insert Suppliers
INSERT INTO Suppliers (SupplierName, ContactEmail, Country) VALUES
('TechCorp Global', 'contact@techcorp.com', 'USA'),
('Apex Logistics', 'support@apexlogistics.cn', 'China'),
('Nordic Goods', 'info@nordicgoods.se', 'Sweden'),
('IndoCraft Industries', 'sales@indocraft.in', 'India');

-- 2. Insert Products
INSERT INTO Products (ProductName, Category, Price, StockQuantity, SupplierID) VALUES
('Wireless Gaming Mouse', 'Electronics', 49.99, 150, 1),
('Mechanical Keyboard', 'Electronics', 89.99, 120, 1),
('Ergonomic Office Chair', 'Furniture', 199.99, 45, 3),
('Standing Desk Frame', 'Furniture', 299.99, 30, 3),
('Stainless Steel Water Bottle', 'Home & Kitchen', 24.99, 300, 4),
('Cotton Bed Sheet Set', 'Home & Kitchen', 45.00, 200, 4),
('USB-C Hub Multiport', 'Electronics', 35.50, 250, 2),
('LED Desk Lamp', 'Home & Kitchen', 29.99, 180, 2);

-- 3. Insert Customers
INSERT INTO Customers (FirstName, LastName, Email, Region, SignupDate) VALUES
('Aman', 'Kumar', 'aman.kumar@example.com', 'North', '2025-01-15'),
('Priya', 'Sharma', 'priya.sharma@example.com', 'South', '2025-02-10'),
('Rahul', 'Verma', 'rahul.verma@example.com', 'East', '2025-03-05'),
('Neha', 'Singh', 'neha.singh@example.com', 'West', '2025-04-12'),
('Vikram', 'Patel', 'vikram.patel@example.com', 'North', '2025-05-20'),
('Ananya', 'Das', 'ananya.das@example.com', 'East', '2025-06-18');

-- 4. Insert Orders
INSERT INTO Orders (CustomerID, OrderDate, Status, TotalAmount) VALUES
(1, '2026-01-10 10:30:00', 'Delivered', 139.98),
(2, '2026-01-15 14:20:00', 'Delivered', 199.99),
(3, '2026-02-02 09:15:00', 'Shipped', 49.99),
(1, '2026-02-20 16:45:00', 'Delivered', 335.49),
(4, '2026-03-01 11:10:00', 'Pending', 45.00),
(5, '2026-03-10 13:00:00', 'Delivered', 299.99),
(2, '2026-03-15 17:30:00', 'Shipped', 60.49),
(6, '2026-04-01 10:00:00', 'Delivered', 120.00);

-- 5. Insert Order Items
INSERT INTO Order_Items (OrderID, ProductID, Quantity, Discount) VALUES
(1, 1, 2, 5.00),  -- 2x Mouse with 5% discount
(1, 7, 1, 0.00),  -- 1x USB-C Hub
(2, 3, 1, 0.00),  -- 1x Office Chair
(3, 1, 1, 10.00), -- 1x Mouse with 10% discount
(4, 4, 1, 0.00),  -- 1x Standing Desk
(4, 5, 2, 5.00),  -- 2x Water Bottles
(5, 6, 1, 0.00),  -- 1x Bed Sheet Set
(6, 4, 1, 0.00),  -- 1x Standing Desk
(7, 5, 1, 0.00),  -- 1x Water Bottle
(7, 8, 1, 0.00),  -- 1x LED Desk Lamp
(8, 2, 1, 0.00),  -- 1x Keyboard
(8, 5, 1, 0.00);  -- 1x Water Bottle

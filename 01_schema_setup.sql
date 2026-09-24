-- =====================================================================
-- Project Name: Advanced E-Commerce & Supply Chain Analytics Engine
-- Database: PostgreSQL
-- Description: Schema setup including tables, constraints, and relationships
-- =====================================================================

-- Drop tables if they already exist (to avoid conflicts on re-run)
DROP TABLE IF EXISTS Inventory_Logs CASCADE;
DROP TABLE IF EXISTS Order_Items CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Products CASCADE;
DROP TABLE IF EXISTS Suppliers CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;

-- 1. Customers Table
CREATE TABLE Customers (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Region VARCHAR(50) NOT NULL,
    SignupDate DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 2. Suppliers Table
CREATE TABLE Suppliers (
    SupplierID SERIAL PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100),
    Country VARCHAR(50) NOT NULL
);

-- 3. Products Table
CREATE TABLE Products (
    ProductID SERIAL PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    StockQuantity INT NOT NULL CHECK (StockQuantity >= 0),
    SupplierID INT,
    CONSTRAINT fk_product_supplier 
        FOREIGN KEY (SupplierID) 
        REFERENCES Suppliers(SupplierID) 
        ON DELETE SET NULL
);

-- 4. Orders Table
CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    TotalAmount DECIMAL(12, 2) DEFAULT 0.00,
    CONSTRAINT fk_order_customer 
        FOREIGN KEY (CustomerID) 
        REFERENCES Customers(CustomerID) 
        ON DELETE CASCADE
);

-- 5. Order_Items Table (Bridge table for Many-to-Many between Orders and Products)
CREATE TABLE Order_Items (
    OrderItemID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Discount DECIMAL(5, 2) DEFAULT 0.00 CHECK (Discount >= 0 AND Discount <= 100),
    LineTotal DECIMAL(12, 2) GENERATED ALWAYS AS (Quantity * (1 - Discount / 100.0)) STORED,
    CONSTRAINT fk_orderitem_order 
        FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID) 
        ON DELETE CASCADE,
    CONSTRAINT fk_orderitem_product 
        FOREIGN KEY (ProductID) 
        REFERENCES Products(ProductID) 
        ON DELETE RESTRICT
);

-- 6. Inventory_Logs Table (For Auditing & Tracking Stock Changes)
CREATE TABLE Inventory_Logs (
    LogID SERIAL PRIMARY KEY,
    ProductID INT NOT NULL,
    OldStock INT NOT NULL,
    NewStock INT NOT NULL,
    ChangeType VARCHAR(50) NOT NULL, -- e.g., 'RESTOCK', 'ORDER_PLACED', 'RETURN'
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product 
        FOREIGN KEY (ProductID) 
        REFERENCES Products(ProductID) 
        ON DELETE CASCADE
);

-- =====================================================================
-- Initial Indexing Strategy for Performance Tuning
-- =====================================================================
CREATE INDEX idx_customers_region ON Customers(Region);
CREATE INDEX idx_orders_customer ON Orders(CustomerID);
CREATE INDEX idx_orders_date ON Orders(OrderDate);
CREATE INDEX idx_products_category ON Products(Category);
  

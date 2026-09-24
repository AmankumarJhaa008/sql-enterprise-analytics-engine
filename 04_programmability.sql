-- =====================================================================
-- Project Name: Advanced E-Commerce & Supply Chain Analytics Engine
-- Description: Stored Procedures, Transactions, and Audit Triggers
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. STORED PROCEDURE: Automated Order Placement with Stock Validation & Transactions
-- Purpose: Safely place an order, update stock, log inventory changes, and handle errors.
-- ---------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE sp_PlaceNewOrder(
    p_CustomerID INT,
    p_ProductID INT,
    p_Quantity INT,
    p_Discount DECIMAL(5, 2) DEFAULT 0.00
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_CurrentStock INT;
    v_ProductPrice DECIMAL(10, 2);
    v_LineTotal DECIMAL(12, 2);
    v_NewOrderID INT;
    v_OldStock INT;
BEGIN
    -- Step 1: Check if product exists and fetch current stock & price
    SELECT StockQuantity, Price 
    INTO v_CurrentStock, v_ProductPrice
    FROM Products 
    WHERE ProductID = p_ProductID;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product with ID % does not exist.', p_ProductID;
    END IF;

    -- Step 2: Validate if sufficient stock is available
    IF v_CurrentStock < p_Quantity THEN
        RAISE EXCEPTION 'Insufficient stock! Available: %, Requested: %', v_CurrentStock, p_Quantity;
    END IF;

    -- Step 3: Calculate line total with discount
    v_LineTotal := (v_ProductPrice * p_Quantity) * (1 - p_Discount / 100.0);
    v_OldStock := v_CurrentStock;

    -- Step 4: Begin Transaction block (Atomicity)
    -- Insert into Orders table
    INSERT INTO Orders (CustomerID, OrderDate, Status, TotalAmount)
    VALUES (p_CustomerID, CURRENT_TIMESTAMP, 'Pending', v_LineTotal)
    RETURNING OrderID INTO v_NewOrderID;

    -- Insert into Order_Items table
    INSERT INTO Order_Items (OrderID, ProductID, Quantity, Discount)
    VALUES (v_NewOrderID, p_ProductID, p_Quantity, p_Discount);

    -- Update Product Stock
    UPDATE Products 
    SET StockQuantity = StockQuantity - p_Quantity
    WHERE ProductID = p_ProductID;

    -- Log the inventory change
    INSERT INTO Inventory_Logs (ProductID, OldStock, NewStock, ChangeType)
    VALUES (p_ProductID, v_OldStock, v_OldStock - p_Quantity, 'ORDER_PLACED');

    RAISE NOTICE 'Order successfully placed! Order ID: %, Total Amount: %', v_NewOrderID, v_LineTotal;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error encountered: %. Transaction rolled back.', SQLERRM;
        ROLLBACK;
END;
$$;


-- ---------------------------------------------------------------------
-- 2. AUDIT TRIGGER & FUNCTION: Tracking Product Price Updates
-- Purpose: Automatically log price changes into audit logs for compliance/history.
-- ---------------------------------------------------------------------

-- Function executed by the trigger
CREATE OR REPLACE FUNCTION fn_AuditProductPriceChange()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Price IS DISTINCT FROM NEW.Price THEN
        INSERT INTO Inventory_Logs (ProductID, OldStock, NewStock, ChangeType, UpdatedAt)
        VALUES (
            NEW.ProductID, 
            OLD.StockQuantity, 
            NEW.StockQuantity, 
            CONCAT('PRICE_UPDATE: From $', OLD.Price, ' to $', NEW.Price),
            CURRENT_TIMESTAMP
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attaching the trigger to the Products table
DROP TRIGGER IF EXISTS trg_LogPriceChange ON Products;
CREATE TRIGGER trg_LogPriceChange
    AFTER UPDATE ON Products
    FOR EACH ROW
    EXECUTE FUNCTION fn_AuditProductPriceChange();

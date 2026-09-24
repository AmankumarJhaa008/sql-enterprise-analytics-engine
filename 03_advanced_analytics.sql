-- =====================================================================
-- Project Name: Advanced E-Commerce & Supply Chain Analytics Engine
-- Description: Complex analytical queries utilizing CTEs and Window Functions
-- =====================================================================

-- ---------------------------------------------------------------------
-- Query 1: Customer Segmentation & Ranking via RFM-style Monetary Metric (Window Functions)
-- Purpose: Classify customers based on their total spending using NTILE
-- ---------------------------------------------------------------------
WITH CustomerSpending AS (
    SELECT 
        c.CustomerID,
        c.FirstName || ' ' || c.LastName AS CustomerName,
        c.Region,
        COUNT(o.OrderID) AS TotalOrders,
        COALESCE(SUM(o.TotalAmount), 0.00) AS LifetimeSpent
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Region
)
SELECT 
    CustomerID,
    CustomerName,
    Region,
    TotalOrders,
    LifetimeSpent,
    NTILE(3) OVER (ORDER BY LifetimeSpent DESC) AS SpendingTier 
    -- Tier 1: Top Spenders, Tier 3: Low Spenders
FROM CustomerSpending;


-- ---------------------------------------------------------------------
-- Query 2: Running Total & Moving Average of Sales (Window Frames)
-- Purpose: Track cumulative revenue growth over time ordered by order date
-- ---------------------------------------------------------------------
SELECT 
    OrderID,
    CustomerID,
    OrderDate::date AS OrderDate,
    TotalAmount,
    SUM(TotalAmount) OVER (ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalRevenue,
    AVG(TotalAmount) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvgLast3Orders
FROM Orders
WHERE Status != 'Cancelled';


-- ---------------------------------------------------------------------
-- Query 3: Product Category Performance & Revenue Share (CTEs & Aggregations)
-- Purpose: Find total revenue and percentage contribution of each product category
-- ---------------------------------------------------------------------
WITH CategorySales AS (
    SELECT 
        p.Category,
        SUM(oi.Quantity) AS TotalUnitsSold,
        SUM(oi.LineTotal) AS CategoryRevenue
    FROM Products p
    JOIN Order_Items oi ON p.ProductID = oi.ProductID
    GROUP BY p.Category
),
OverallSales AS (
    SELECT SUM(CategoryRevenue) AS GrandTotal FROM CategorySales
)
SELECT 
    cs.Category,
    cs.TotalUnitsSold,
    cs.CategoryRevenue,
    ROUND((cs.CategoryRevenue / os.GrandTotal) * 100, 2) AS RevenueSharePercentage
FROM CategorySales cs
CROSS JOIN OverallSales os
ORDER BY CategoryRevenue DESC;


-- ---------------------------------------------------------------------
-- Query 4: Month-over-Month (MoM) Revenue Growth (LAG Function)
-- Purpose: Calculate monthly revenue changes using time-series window analysis
-- ---------------------------------------------------------------------
WITH MonthlyRevenue AS (
    SELECT 
        DATE_TRUNC('month', OrderDate)::date AS OrderMonth,
        SUM(TotalAmount) AS MonthlyRevenue
    FROM Orders
    WHERE Status != 'Cancelled'
    GROUP BY DATE_TRUNC('month', OrderDate)
)
SELECT 
    OrderMonth,
    MonthlyRevenue,
    LAG(MonthlyRevenue, 1) OVER (ORDER BY OrderMonth) AS PreviousMonthRevenue,
    ROUND(
        ((MonthlyRevenue - LAG(MonthlyRevenue, 1) OVER (ORDER BY OrderMonth)) / 
         NULLIF(LAG(MonthlyRevenue, 1) OVER (ORDER BY OrderMonth), 0)) * 100, 2
    ) AS MoM_Growth_Percentage
FROM MonthlyRevenue;

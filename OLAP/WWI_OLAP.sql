-- USE DATA WAREHOUSE DATABASE
USE WWI_DW;

-- CUSTOMER ANALYSIS USING OLAP
WITH CUSTOMER_SPENDINGS AS (
	-- SELECT COLUMNS
	SELECT  c.CustomerID, 
			c.CustomerName,
			c.CustomerCity,
			c.CustomerCountry,
			p.ProductName, 
			p.ProductGroup,
			s.SalesQuantity, 
			s.SalesAmount
	-- DEFINE TABLES
	FROM dbo.FactSales s
	LEFT JOIN dbo.DimCustomer c
	ON c.CustomerID = s.CustomerID
	LEFT JOIN dbo.DimProduct p
	ON s.StockItemID = p.ProductID
)

SELECT * 
FROM CUSTOMER_SPENDINGS;

--HIGHEST SALES GROUPED BY PRODUCTGROUP
WITH PRODUCT_SALES AS (
	SELECT  p.ProductGroup,
			SUM(s.SalesAmount) AS SUM_SALES
	FROM dbo.FactSales s
	LEFT JOIN dbo.DimProduct p
	ON s.StockItemID = p.ProductID
	GROUP BY p.ProductGroup
)

SELECT  ProductGroup, 
		SUM_SALES,
		RANK() OVER(
			ORDER BY SUM_SALES DESC
		) AS SALES_RANK
FROM PRODUCT_SALES;

--PRODUCT GROUPS WITH HIGHEST SPENDINGS OVERTIME
WITH LOCATION_SPENDS AS (
	SELECT  d.Month,
			p.ProductGroup,
			SUM(s.SalesAmount) AS SUM_SALES
	FROM dbo.FactSales s
	LEFT JOIN dbo.DimProduct p
	ON s.StockItemID = p.ProductID
	LEFT JOIN dbo.DimDate d
	ON s.Date_key = d.Date_key
	GROUP BY CUBE(d.Month,p.ProductGroup)
)

SELECT *
FROM LOCATION_SPENDS;

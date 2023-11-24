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

--AVERAGE PROFIT PER DAY
SELECT
   d.Year,
   d.Month,
   d.Day,
   AVG(s.ProfitAmount) AS AVG_PROFIT_AMOUNT,
   DENSE_RANK() OVER(
	ORDER BY AVG(s.ProfitAmount) DESC
   ) AS DENSE_RANK_AVG_PROFIT
   
FROM dbo.FactSales s
LEFT JOIN dbo.DimDate d
ON s.Date_key = d.Date_key
GROUP BY d.Year, d.Month, d.Day
ORDER BY d.Year, d.Month, d.Day;

--ROLLING AVERAGE
SELECT
   d.Year,
   d.Month,
   d.Day,
   s.SalesAmount,
   ROUND(AVG(s.SalesAmount)
         OVER(PARTITION BY d.Day
			  ORDER BY d.Full_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW), 2)
         AS SALES_MOVING_AVERAGE
FROM dbo.FactSales s
LEFT JOIN dbo.DimDate d
ON s.Date_key = d.Date_key
ORDER BY d.Year, d.Month, d.Day;

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


--OLAP METHODS FOR ADVANCED GROUPING

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

--SALESPERSON OLAP
with salesperson_sells as (
	select  e.SalesPersonID
			, e.SalesPersonName
			, e.SalesPersonPhoneNumber
			, e.SalesPersonEmail
			, count(s.SalespersonPersonID) as salesperson_count
			, rank() over(
				order by count(s.SalespersonPersonID) desc
			) as salesperson_rankings
	from dbo.FactSales s
	left join dbo.DimSalesperson e
	on s.SalespersonPersonID = e.SalesPersonID
	group by e.SalesPersonID
			 , e.SalesPersonName
			 , e.SalesPersonPhoneNumber
			 , e.SalesPersonEmail
)
--GET TOP 3 MOST SELLING SALESPEOPLE
select *
from salesperson_sells
where salesperson_rankings in (1,2,3);
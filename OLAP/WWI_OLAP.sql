-- USE DATA WAREHOUSE DATABASE
USE WWI_DW;

-- CUSTOMER ANALYSIS USING OLAP
WITH CUSTOMER_SPENDINGS AS (
	-- SELECT COLUMNS
	SELECT  c.CustomerID, 
			d.Full_date,
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
	LEFT JOIN dbo.DimDate d
	ON s.Date_key = d.Date_key
)

SELECT * 
FROM CUSTOMER_SPENDINGS;

--AVERAGE PROFIT FROM PRODUCTS
WITH all_time_avg_profit AS (
	SELECT	p.ProductName
			, SUM(s.ProfitAmount) AS avg_profit
			, RANK() OVER (
				ORDER BY AVG(s.ProfitAmount) DESC
			) AS profit_rank
	FROM dbo.FactSales s
	LEFT JOIN dbo.DimProduct p
	ON s.StockItemID = p.ProductID
	GROUP BY p.ProductName
)

SELECT *
FROM all_time_avg_profit
ORDER BY profit_rank;

--AVERAGE PROFIT PER DAY
SELECT
   d.Year,
   d.Month,
   p.ProductName,
   SUM(s.ProfitAmount) AS SUM_PROFIT_AMOUNT,
   DENSE_RANK() OVER(
	PARTITION BY d.Year,d.Month
	ORDER BY SUM(s.ProfitAmount) DESC
   ) AS DENSE_RANK_SUM_PROFIT
   
FROM dbo.FactSales s
LEFT JOIN dbo.DimDate d
ON s.Date_key = d.Date_key
LEFT JOIN dbo.DimProduct p
ON s.StockItemID = p.ProductID
GROUP BY d.Year, d.Month, p.ProductName;

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
			, count(s.SalespersonPersonID) as sales_count
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

--PRODUCT SALES OVER TIME WITH ROLLUP
WITH product_sales_over_time AS (
	SELECT	d.Full_date
			, p.ProductName
			, SUM(s.SalesAmount) AS sum_sales
	FROM dbo.FactSales s
	LEFT JOIN dbo.DimProduct p
	ON s.StockItemID = p.ProductID
	LEFT JOIN dbo.DimDate d
	ON s.Date_key = d.Date_key
	GROUP BY ROLLUP(d.Full_date, p.ProductName)
)

SELECT *
FROM product_sales_over_time;


--COST ANALYSIS (DOES THE PRODUCT WITH THE HIGHEST COST MAKES THE HIGHEST PROFIT?)
WITH all_sales AS (
	SELECT	DISTINCT(p.ProductName)
			, s.UnitCost
			, s.UnitProfit
			, DENSE_RANK() OVER (
				ORDER BY s.UnitProfit DESC
			) AS profit_rank
	FROM dbo.FactSales s
	LEFT JOIN dbo.DimProduct p
	ON s.StockItemID = p.ProductID
)

SELECT * 
FROM all_sales
ORDER BY UnitCost DESC;

SELECT d.Year,
		d.Month,
		d.Day,
			SUM(s.SalesAmount) AS TOTAL_SALES
FROM dbo.FactSales s
LEFT JOIN dbo.DimDate d
ON s.Date_key = d.Date_key
GROUP BY CUBE(d.Year,
		d.Month,
		d.Day);
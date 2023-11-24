# Diagrams

The design of the Data Warehouse was drawn in an information package and star schema with respective attributes :


> Dimensions

  (-) Date Dimension : represent customer purchase dates
  
  (-) Product Dimension : represent the products that in transactions
  
  (-) Customer Dimension : represent data of customers in each transaction.
  
  (-) Salesperson Dimension : represent salesperson(s) that makes the transaction happen.
  

> Facts

  (-) UnitPrice : price of a single product unit
  
  (-) UnitProfit : profit made from a single product unit
  
  (-) UnitCost : cost from a single product unit
  
  (-) TaxAmount : total tax from transaction
  
  (-) SalesQuantity : quantity of units in a transaction
  
  (-) SalesAmount : UnitPrice * SalesQuantity
  
  (-) CostAmount : UnitCost * SalesQuantity
  
  (-) ProfitAmount : UnitProfit * SalesQuantity
  
  (-) TotalPriceWithoutTax : SalesAmount - TaxAmount

/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Purpose:
    This script checks the quality and integrity of the Gold Layer.

    The Gold Layer contains the final Star Schema objects:
    - Dimension views
    - Fact views

Checks Included:
    1. Surrogate key uniqueness in dimensions
    2. Fact-to-dimension relationship checks
    3. Data model connectivity validation

Usage:
    Run this script after creating Gold views.

    Example:
        SELECT * FROM gold.dim_customers;
        SELECT * FROM gold.dim_products;
        SELECT * FROM gold.fact_sales;

Expected Result:
    All quality checks should return no rows.

    If a query returns rows, those records need investigation.
===============================================================================
*/


/*=============================================================================
  1. CHECK: gold.dim_customers
=============================================================================*/


/*-----------------------------------------------------------------------------
  1.1 Check Customer Surrogate Key Uniqueness
  Goal:
      Make sure each customer_key appears only once.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


/*-----------------------------------------------------------------------------
  1.2 Check Customer Business Key Uniqueness
  Goal:
      Make sure each customer_number appears only once.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    customer_number,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1;


/*-----------------------------------------------------------------------------
  1.3 Check Customer Gender Values
  Goal:
      Make sure gender values are standardized.

  Expected Values:
      Female
      Male
      n/a
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    gender
FROM gold.dim_customers;


/*=============================================================================
  2. CHECK: gold.dim_products
=============================================================================*/


/*-----------------------------------------------------------------------------
  2.1 Check Product Surrogate Key Uniqueness
  Goal:
      Make sure each product_key appears only once.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


/*-----------------------------------------------------------------------------
  2.2 Check Product Business Key Uniqueness
  Goal:
      Make sure each product_number appears only once.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    product_number,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;


/*-----------------------------------------------------------------------------
  2.3 Check Product Category Values
  Goal:
      Review category and subcategory values.
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    category,
    subcategory
FROM gold.dim_products
ORDER BY
    category,
    subcategory;


/*=============================================================================
  3. CHECK: gold.fact_sales
=============================================================================*/


/*-----------------------------------------------------------------------------
  3.1 Check Data Model Connectivity
  Goal:
      Make sure every fact record connects to customer and product dimensions.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    f.*
FROM gold.fact_sales f

LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key

LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key

WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;


/*-----------------------------------------------------------------------------
  3.2 Check Missing Customer Keys
  Goal:
      Find sales records without a valid customer dimension match.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    f.*
FROM gold.fact_sales f

LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key

WHERE c.customer_key IS NULL;


/*-----------------------------------------------------------------------------
  3.3 Check Missing Product Keys
  Goal:
      Find sales records without a valid product dimension match.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    f.*
FROM gold.fact_sales f

LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key

WHERE p.product_key IS NULL;


/*-----------------------------------------------------------------------------
  3.4 Check Sales Measures
  Goal:
      Make sure sales measures are valid.

  Rule:
      sales_amount = quantity * price

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    order_number,
    sales_amount,
    quantity,
    price
FROM gold.fact_sales
WHERE sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL
   OR sales_amount <= 0
   OR quantity <= 0
   OR price <= 0
   OR sales_amount != quantity * price;


/*-----------------------------------------------------------------------------
  3.5 Final Look at Gold Fact Sales
  Goal:
      Review final fact data.
-----------------------------------------------------------------------------*/

SELECT TOP (1000)
    *
FROM gold.fact_sales;

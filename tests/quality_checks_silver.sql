/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Purpose:
    This script checks data quality in the Silver Layer after loading data
    from Bronze to Silver.

Checks Included:
    1. Primary key checks
       - NULL values
       - Duplicate values

    2. String quality checks
       - Unwanted spaces
       - Standardized values

    3. Date quality checks
       - Invalid date ranges
       - Wrong date order

    4. Business rule checks
       - Sales = Quantity * Price

Usage:
    Run this script after executing:

        EXEC silver.load_silver;

Expected Result:
    Most checks should return no rows.
    If a query returns rows, those records need investigation.
===============================================================================
*/


/*=============================================================================
  1. CHECK: silver.crm_cust_info
=============================================================================*/


/*-----------------------------------------------------------------------------
  1.1 Check Primary Key
  Goal:
      Find NULL or duplicate customer IDs.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    cst_id,
    COUNT(*) AS total_records
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


/*-----------------------------------------------------------------------------
  1.2 Check Customer Key Spaces
  Goal:
      Find customer keys with extra spaces.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);


/*-----------------------------------------------------------------------------
  1.3 Check First Name Spaces
  Goal:
      Find first names with extra spaces.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


/*-----------------------------------------------------------------------------
  1.4 Check Last Name Spaces
  Goal:
      Find last names with extra spaces.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


/*-----------------------------------------------------------------------------
  1.5 Check Marital Status Values
  Goal:
      Check standardized marital status values.

  Expected Values:
      Single
      Married
      n/a
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;


/*-----------------------------------------------------------------------------
  1.6 Check Gender Values
  Goal:
      Check standardized gender values.

  Expected Values:
      Female
      Male
      n/a
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info;


/*=============================================================================
  2. CHECK: silver.crm_prd_info
=============================================================================*/


/*-----------------------------------------------------------------------------
  2.1 Check Primary Key
  Goal:
      Find NULL or duplicate product IDs.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    prd_id,
    COUNT(*) AS total_records
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


/*-----------------------------------------------------------------------------
  2.2 Check Product Name Spaces
  Goal:
      Find product names with extra spaces.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


/*-----------------------------------------------------------------------------
  2.3 Check Product Cost
  Goal:
      Find NULL or negative product costs.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


/*-----------------------------------------------------------------------------
  2.4 Check Product Line Values
  Goal:
      Check standardized product line values.

  Expected Values:
      Mountain
      Road
      Other Sales
      Touring
      n/a
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;


/*-----------------------------------------------------------------------------
  2.5 Check Product Date Order
  Goal:
      End date must not be before start date.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/*-----------------------------------------------------------------------------
  2.6 Check Category ID Integrity
  Goal:
      Category ID should exist in ERP category table.

  Expected Result:
      No rows, unless business accepts missing categories.
-----------------------------------------------------------------------------*/

SELECT
    cat_id
FROM silver.crm_prd_info
WHERE cat_id NOT IN
(
    SELECT DISTINCT id
    FROM silver.erp_px_cat_g1v2
);


/*=============================================================================
  3. CHECK: silver.crm_sales_details
=============================================================================*/


/*-----------------------------------------------------------------------------
  3.1 Check Order Date Quality
  Goal:
      Find invalid order dates.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL;


/*-----------------------------------------------------------------------------
  3.2 Check Shipping Date Quality
  Goal:
      Find invalid shipping dates.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL;


/*-----------------------------------------------------------------------------
  3.3 Check Due Date Quality
  Goal:
      Find invalid due dates.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_due_dt IS NULL;


/*-----------------------------------------------------------------------------
  3.4 Check Date Order
  Goal:
      Order date must be before shipping date and due date.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


/*-----------------------------------------------------------------------------
  3.5 Check Sales Business Rule
  Goal:
      Sales must equal Quantity multiplied by Price.

  Rule:
      Sales = Quantity * Price

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;


/*-----------------------------------------------------------------------------
  3.6 Check Product Key Integrity
  Goal:
      Sales product keys should exist in Silver product table.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN
(
    SELECT DISTINCT prd_key
    FROM silver.crm_prd_info
);


/*-----------------------------------------------------------------------------
  3.7 Check Customer ID Integrity
  Goal:
      Sales customer IDs should exist in Silver customer table.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN
(
    SELECT DISTINCT cst_id
    FROM silver.crm_cust_info
);


/*=============================================================================
  4. CHECK: silver.erp_cust_az12
=============================================================================*/


/*-----------------------------------------------------------------------------
  4.1 Check Birth Date Range
  Goal:
      Find very old or future birth dates.

  Expected Result:
      No future dates.
      Very old dates may need business confirmation.
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


/*-----------------------------------------------------------------------------
  4.2 Check Gender Values
  Goal:
      Check standardized gender values.

  Expected Values:
      Female
      Male
      n/a
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


/*-----------------------------------------------------------------------------
  4.3 Check Customer ID Integrity
  Goal:
      ERP customer IDs should match CRM customer keys.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    cid
FROM silver.erp_cust_az12
WHERE cid NOT IN
(
    SELECT DISTINCT cst_key
    FROM silver.crm_cust_info
);


/*=============================================================================
  5. CHECK: silver.erp_loc_a101
=============================================================================*/


/*-----------------------------------------------------------------------------
  5.1 Check Country Values
  Goal:
      Check standardized country values.

  Expected Values:
      Germany
      United States
      United Kingdom
      n/a
      Other valid country names
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


/*-----------------------------------------------------------------------------
  5.2 Check Customer ID Integrity
  Goal:
      Location customer IDs should match CRM customer keys.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    cid
FROM silver.erp_loc_a101
WHERE cid NOT IN
(
    SELECT DISTINCT cst_key
    FROM silver.crm_cust_info
);


/*=============================================================================
  6. CHECK: silver.erp_px_cat_g1v2
=============================================================================*/


/*-----------------------------------------------------------------------------
  6.1 Check Unwanted Spaces
  Goal:
      Find extra spaces in category columns.

  Expected Result:
      No rows.
-----------------------------------------------------------------------------*/

SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);


/*-----------------------------------------------------------------------------
  6.2 Check Maintenance Values
  Goal:
      Check standardized maintenance values.

  Expected Values:
      Yes
      No
-----------------------------------------------------------------------------*/

SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;


/*-----------------------------------------------------------------------------
  6.3 Final Look at Category Table
  Goal:
      Review final category data.
-----------------------------------------------------------------------------*/

SELECT TOP (1000)
    *
FROM silver.erp_px_cat_g1v2;

/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Purpose:
    This script creates views in the Gold Layer.

    The Gold Layer is the final business-ready layer of the data warehouse.
    It contains dimension and fact views for analytics and reporting.

Architecture:
    Silver Layer  ->  Gold Layer
    Clean Data    ->  Star Schema Views

Objects Created:
    1. gold.dim_customers
    2. gold.dim_products
    3. gold.fact_sales

Main Concepts:
    - Dimension views describe business objects.
    - Fact views store business events and measures.
    - Surrogate keys connect facts with dimensions.
    - Friendly column names are used for reporting.

Usage:
    Run this script after the Silver Layer is loaded and checked.

    Example:
        SELECT * FROM gold.dim_customers;
        SELECT * FROM gold.dim_products;
        SELECT * FROM gold.fact_sales;
===============================================================================
*/


/*=============================================================================
  1. Dimension View: gold.dim_customers
===============================================================================
Purpose:
    Creates the customer dimension view.

Source Tables:
    - silver.crm_cust_info
    - silver.erp_cust_az12
    - silver.erp_loc_a101

Business Logic:
    - CRM customer table is the main customer source.
    - ERP customer table adds birthdate and extra gender information.
    - ERP location table adds country information.
    - CRM gender is used first.
    - If CRM gender is not available, ERP gender is used.
    - A surrogate key is generated with ROW_NUMBER().
=============================================================================*/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS

SELECT
    -- Surrogate key for the customer dimension
    ROW_NUMBER() OVER (
        ORDER BY cst_id
    ) AS customer_key,

    -- Customer information from CRM
    ci.cst_id             AS customer_id,
    ci.cst_key            AS customer_number,
    ci.cst_firstname      AS first_name,
    ci.cst_lastname       AS last_name,

    -- Location information from ERP
    la.cntry              AS country,

    -- Customer attributes
    ci.cst_marital_status AS marital_status,

    -- Gender integration rule:
    -- CRM is the primary source.
    -- ERP is used only when CRM gender is not available.
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    -- Additional customer information
    ca.bdate              AS birthdate,
    ci.cst_create_date    AS create_date

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO


/*=============================================================================
  2. Dimension View: gold.dim_products
===============================================================================
Purpose:
    Creates the product dimension view.

Source Tables:
    - silver.crm_prd_info
    - silver.erp_px_cat_g1v2

Business Logic:
    - CRM product table is the main product source.
    - ERP category table adds category details.
    - Only current product records are included.
    - Historical product records are excluded.
    - A surrogate key is generated with ROW_NUMBER().
=============================================================================*/

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS

SELECT
    -- Surrogate key for the product dimension
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    -- Product information from CRM
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,

    -- Category information
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,

    -- Product attributes
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date

FROM silver.crm_prd_info pn

LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id

-- Keep only current product records
WHERE pn.prd_end_dt IS NULL;
GO


/*=============================================================================
  3. Fact View: gold.fact_sales
===============================================================================
Purpose:
    Creates the sales fact view.

Source Tables:
    - silver.crm_sales_details
    - gold.dim_products
    - gold.dim_customers

Business Logic:
    - Sales data comes from the CRM sales table.
    - Product and customer surrogate keys are looked up from Gold dimensions.
    - Source system keys are replaced by data warehouse surrogate keys.
    - Measures are kept at the end of the fact view.

Fact Structure:
    1. Order number
    2. Dimension surrogate keys
    3. Dates
    4. Measures
=============================================================================*/

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS

SELECT
    -- Degenerate dimension
    sd.sls_ord_num  AS order_number,

    -- Surrogate keys from Gold dimensions
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,

    -- Date columns
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,

    -- Measures
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO

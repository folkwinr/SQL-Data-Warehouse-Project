## Executive Summary

This project builds a complete **SQL Server Data Warehouse** that combines CRM and ERP data into a single, trusted, and analytics-ready data model.

Many organizations store business data across multiple systems. Customer data may come from a CRM platform, product information from an ERP system, and sales transactions from another source. This often leads to:

- Inconsistent reports
- Manual data preparation
- Duplicate business logic
- Poor data quality
- Low trust in business metrics

To solve these challenges, this project implements a modern **Medallion Architecture** that organizes data into three layers.

### Data Warehouse Flow

```text
Bronze Layer  →  Silver Layer  →  Gold Layer
Raw Data      →  Clean Data    →  Business-Ready Data
```

### Layer Responsibilities

| Layer | Purpose |
|--------|---------|
| **Bronze** | Loads raw CRM and ERP data using stored procedures and full-load processing |
| **Silver** | Cleans, standardizes, validates, and enriches the data |
| **Gold** | Delivers a business-ready Star Schema for reporting and analytics |

### Gold Layer Output

The final analytical model contains three business views:

- **`gold.dim_customers`** – Customer profiles and demographic information
- **`gold.dim_products`** – Product details and category information
- **`gold.fact_sales`** – Sales transactions, quantities, prices, and revenue

### Data Quality Improvements

The ETL pipeline resolves several common data quality issues, including:

- Duplicate customer records
- Invalid or inconsistent dates
- Standardized gender and country values
- Product history management
- Missing values
- Incorrect sales calculations

### Business Value

The completed data warehouse provides a **Single Source of Truth** that supports:

- Sales reporting
- Customer segmentation
- Product performance analysis
- Ad-hoc SQL analysis
- Business Intelligence dashboards (Power BI, Tableau)

---

This project demonstrates an end-to-end **SQL Server Data Warehouse** implementation, covering ETL development, data transformation, dimensional modeling, data quality validation, and analytics-ready data delivery.

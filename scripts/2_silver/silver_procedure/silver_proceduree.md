# 🥈 Silver Layer - `load_silver` Procedure Structure

The `silver.load_silver` stored procedure loads clean and transformed data from the Bronze Layer into the Silver Layer.

It performs these main actions:

- 🗑️ Truncates Silver tables
- 🧹 Cleans Bronze data
- 🔄 Transforms data based on business rules
- 📥 Inserts clean data into Silver tables
- ⏱️ Prints load duration for each table
- ❌ Handles errors with TRY...CATCH

---

```text
📦 Stored Procedure
(silver.load_silver)
│
├── 🟦 BEGIN
│
├── 📋 DECLARE
│   │
│   ├── ⏱️ @start_time
│   ├── ⏱️ @end_time
│   ├── ⏳ @batch_start_time
│   └── ⏳ @batch_end_time
│
├── 🟢 BEGIN TRY
│   │
│   ├── ⏰ Batch Start Time
│   │   └── SET @batch_start_time
│   │
│   ├── 🖨️ PRINT
│   │   └── Loading Silver Layer
│   │
│   ├── 🧩 CRM TABLES
│   │   │
│   │   ├── 👥 silver.crm_cust_info
│   │   │   │
│   │   │   ├── ⏰ Start Time
│   │   │   ├── 🗑️ TRUNCATE
│   │   │   ├── 📥 INSERT INTO Silver
│   │   │   │   │
│   │   │   │   ├── 🧹 Trim first name
│   │   │   │   ├── 🧹 Trim last name
│   │   │   │   ├── 🔄 Standardize marital status
│   │   │   │   │   ├── S → Single
│   │   │   │   │   ├── M → Married
│   │   │   │   │   └── Others → n/a
│   │   │   │   │
│   │   │   │   ├── 🔄 Standardize gender
│   │   │   │   │   ├── F → Female
│   │   │   │   │   ├── M → Male
│   │   │   │   │   └── Others → n/a
│   │   │   │   │
│   │   │   │   ├── 🚫 Remove NULL customer IDs
│   │   │   │   └── 🥇 Keep latest customer record
│   │   │   │       └── ROW_NUMBER()
│   │   │   │
│   │   │   ├── ⏰ End Time
│   │   │   └── 🖨️ Print Duration
│   │   │
│   │   ├── 📦 silver.crm_prd_info
│   │   │   │
│   │   │   ├── ⏰ Start Time
│   │   │   ├── 🗑️ TRUNCATE
│   │   │   ├── 📥 INSERT INTO Silver
│   │   │   │   │
│   │   │   │   ├── 🏷️ Create Category ID
│   │   │   │   │   └── AC-HE → AC_HE
│   │   │   │   │
│   │   │   │   ├── 🔑 Create Product Key
│   │   │   │   │   └── Extract second part of prd_key
│   │   │   │   │
│   │   │   │   ├── 💰 Fix Product Cost
│   │   │   │   │   └── NULL → 0
│   │   │   │   │
│   │   │   │   ├── 🔄 Standardize Product Line
│   │   │   │   │   ├── M → Mountain
│   │   │   │   │   ├── R → Road
│   │   │   │   │   ├── S → Other Sales
│   │   │   │   │   ├── T → Touring
│   │   │   │   │   └── Others → n/a
│   │   │   │   │
│   │   │   │   ├── 📅 Cast Start Date
│   │   │   │   │   └── DATETIME → DATE
│   │   │   │   │
│   │   │   │   └── 📅 Create End Date
│   │   │   │       └── Next Start Date - 1 Day
│   │   │   │
│   │   │   ├── ⏰ End Time
│   │   │   └── 🖨️ Print Duration
│   │   │
│   │   └── 💰 silver.crm_sales_details
│   │       │
│   │       ├── ⏰ Start Time
│   │       ├── 🗑️ TRUNCATE
│   │       ├── 📥 INSERT INTO Silver
│   │       │   │
│   │       │   ├── 📅 Clean Order Date
│   │       │   │   ├── 0 → NULL
│   │       │   │   ├── Invalid length → NULL
│   │       │   │   └── Valid value → DATE
│   │       │   │
│   │       │   ├── 📅 Clean Shipping Date
│   │       │   │   ├── 0 → NULL
│   │       │   │   ├── Invalid length → NULL
│   │       │   │   └── Valid value → DATE
│   │       │   │
│   │       │   ├── 📅 Clean Due Date
│   │       │   │   ├── 0 → NULL
│   │       │   │   ├── Invalid length → NULL
│   │       │   │   └── Valid value → DATE
│   │       │   │
│   │       │   ├── 🧮 Fix Sales
│   │       │   │   ├── NULL → Quantity × Price
│   │       │   │   ├── Zero → Quantity × Price
│   │       │   │   ├── Negative → Quantity × ABS(Price)
│   │       │   │   └── Wrong calculation → Quantity × ABS(Price)
│   │       │   │
│   │       │   ├── 📦 Keep Quantity
│   │       │   │
│   │       │   └── 🧮 Fix Price
│   │       │       ├── NULL → Sales ÷ Quantity
│   │       │       ├── Zero → Sales ÷ Quantity
│   │       │       └── Negative → Sales ÷ Quantity
│   │       │
│   │       ├── ⏰ End Time
│   │       └── 🖨️ Print Duration
│   │
│   ├── 🧩 ERP TABLES
│   │   │
│   │   ├── 👤 silver.erp_cust_az12
│   │   │   │
│   │   │   ├── ⏰ Start Time
│   │   │   ├── 🗑️ TRUNCATE
│   │   │   ├── 📥 INSERT INTO Silver
│   │   │   │   │
│   │   │   │   ├── 🔑 Clean Customer ID
│   │   │   │   │   └── Remove NAS prefix
│   │   │   │   │
│   │   │   │   ├── 🎂 Clean Birth Date
│   │   │   │   │   └── Future dates → NULL
│   │   │   │   │
│   │   │   │   └── 🔄 Standardize Gender
│   │   │   │       ├── F / Female → Female
│   │   │   │       ├── M / Male → Male
│   │   │   │       └── Others → n/a
│   │   │   │
│   │   │   ├── ⏰ End Time
│   │   │   └── 🖨️ Print Duration
│   │   │
│   │   ├── 🌍 silver.erp_loc_a101
│   │   │   │
│   │   │   ├── ⏰ Start Time
│   │   │   ├── 🗑️ TRUNCATE
│   │   │   ├── 📥 INSERT INTO Silver
│   │   │   │   │
│   │   │   │   ├── 🔑 Clean Customer ID
│   │   │   │   │   └── Remove "-"
│   │   │   │   │
│   │   │   │   └── 🌍 Standardize Country
│   │   │   │       ├── DE → Germany
│   │   │   │       ├── US / USA → United States
│   │   │   │       ├── NULL / Empty → n/a
│   │   │   │       └── Others → Trimmed value
│   │   │   │
│   │   │   ├── ⏰ End Time
│   │   │   └── 🖨️ Print Duration
│   │   │
│   │   └── 🏷️ silver.erp_px_cat_g1v2
│   │       │
│   │       ├── ⏰ Start Time
│   │       ├── 🗑️ TRUNCATE
│   │       ├── 📥 INSERT INTO Silver
│   │       │   │
│   │       │   ├── id
│   │       │   ├── cat
│   │       │   ├── subcat
│   │       │   └── maintenance
│   │       │
│   │       ├── ℹ️ No transformation needed
│   │       ├── ⏰ End Time
│   │       └── 🖨️ Print Duration
│   │
│   ├── ⏰ Batch End Time
│   │   └── SET @batch_end_time
│   │
│   └── 🖨️ Success Message
│       └── Total Load Duration
│
├── 🔴 BEGIN CATCH
│   │
│   ├── ❌ ERROR_MESSAGE()
│   ├── 🔢 ERROR_NUMBER()
│   ├── 📍 ERROR_STATE()
│   └── 🖨️ Print Error
│
└── 🟦 END

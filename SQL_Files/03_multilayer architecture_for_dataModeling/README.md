# Multi-Layer Analytics Architecture for MobileAppRetail_DB

This repository contains the SQL scripts for building a **multi-layer data architecture** for data modeling on top of the `MobileAppRetail_DB` database.  
The structure supports staging, dimensional modeling, and fact tables for analytical purposes. This architecture enables efficient querying, historical tracking, and easy integration with BI tools.
For more details, such as Business Rules, Data Dictionary, and Cleansing Rules, you need to check the PDF file, presenting this portfolio. 

## Architecture Overview

The multi-layer architecture is designed with the following layers:

1. **Staging Layer**  
   - Cleans, validates, and transforms raw transactional and event data.  
   - Creates intermediate views ready for dimensional and fact tables.  
   - Examples: `Stg_Sessions`, `Stg_Events`, `Stg_Invoices_With_User`, `Stg_Device`.

2. **Dimension Layer (Dim)**  
   - Stores descriptive entities for analytical purposes.  
   - Implements Slowly Changing Dimensions (SCD) where needed:
     - **Type 0**: Immutable (e.g., `Dim_Timestamp`)  
     - **Type 1**: Overwrite (e.g., `Dim_Devices`, `Dim_StockCodes`)  
     - **Type 2**: Historical tracking (e.g., `Dim_User`)  
   - Examples: `Dim_User`, `Dim_Devices`, `Dim_Event_Type`, `Dim_StockCodes`.

3. **Fact Layer (Fact)**  
   - Stores measurable events and transactions for analysis.  
   - Surrogate keys link facts to dimensions for optimized joins.  
   - Examples: `Fact_Sessions`, `Fact_Events`, `Fact_Invoices`, `Fact_Invoice_Items`.

---

## Folder Structure & Files

| File Name | Description |
|-----------|-------------|
| `01_staging_views.sql` | Scripts to create staging views for sessions, events, invoices, and devices. |
| `02_dim_user.sql` | Creates `Dim_User` (SCD Type 2) and supporting user/device mapping. |
| `03_dim_devices.sql` | Creates `Dim_Devices` table (SCD Type 1) and `User_Device_map` table for fast joins. |
| `04_dim_timestamp.sql` | Creates `Dim_Timestamp` and `Dim_Timestamp_Minute` views. |
| `05_dim_event_stock.sql` | Creates `Dim_Event_Type` and `Dim_StockCodes` views. |
| `06_fact_sessions.sql` | Creates `Fact_Sessions` table and inserts data from staging. |
| `07_fact_events.sql` | Creates `Fact_Events` table and inserts data from staging. |
| `08_fact_invoices.sql` | Creates `Fact_Invoices` and `Fact_Invoice_Items` tables and inserts data. |

> **Note:** All staging views reference the original `Users`, `Events`, and `Transaction` schemas.

---


## ERD References

- Conceptual and Logical ERDs for this multi-layer architecture:
![Conceptual ERD](https://github.com/GhazalSavoji/Portfolio_Retail_App/blob/main/Images/Conceptual%20ERD%20galaxy%20schema.png?raw=true)
![Logical ERD](https://github.com/GhazalSavoji/Portfolio_Retail_App/blob/main/Images/logical%20erd%20galaxy%20schema.png?raw=true)

---

## Usage Instructions

1. Make sure the **MobileAppRetail_DB** database is created and populated with raw CSV data.  
2. Run scripts in **order** to create staging, dimensions, and fact tables:  
   `01_staging_views.sql` → `02_dim_user.sql` → `03_dim_devices.sql` → `04_dim_timestamp.sql` → `05_dim_event_stock.sql` → `06_fact_sessions.sql` → `07_fact_events.sql` → `08_fact_invoices.sql`.  
3. Verify each layer by running the `SELECT TOP 10` or `COUNT(*)` queries included in each script.  
4. Once all scripts are executed, the database is ready for analytical queries, reporting, and integration with BI tools like Power BI.

---

## Notes

- **Data cleaning**: Nulls, outliers, and type conversions are handled in staging views.  
- **SCD strategy**: Maintains historical records for users while overwriting other dimensions for current state.  
- **Indexes**: Added on key columns for optimized joins between dimensions and facts.  
- **Testing**: Each script contains sample `SELECT` queries to quickly inspect row counts and data correctness.

---

## Sample Queries

- Retrieve top users by session duration:  
```sql
SELECT TOP 10 u.user_id, SUM(f.session_duration_sec) AS total_duration
FROM Fact.Fact_Sessions f
JOIN Dim.Dim_User u ON f.user_sk = u.user_sk
GROUP BY u.user_id
ORDER BY total_duration DESC;

# 01_create_database

This folder contains all SQL scripts required to create the **MobileAppRetail_DB** database from intermediate CSV files.  
It includes table creation, data cleaning, data type conversions, primary and foreign key definitions, and indexes for optimized joins.

## Folder Structure & File Overview

| File Name | Description |
|-----------|-------------|
| `00_create_db.sql` | Creates the database `MobileAppRetail_DB` and schemas (`Users`, `Events`, `Transaction`). |
| `01_create_user_table.sql` | Creates the `Users.[user]` table, imports CSV data, cleans `user_age` and `is_subscribed`, converts data types, sets primary key. |
| `02_create_device_table.sql` | Creates the `Users.[device]` table, imports CSV, sets foreign key to `Users.[user]`. |
| `03_create_session_table.sql` | Creates the `Events.[session]` table, imports CSV, performs data cleaning and type conversion, sets foreign key to `Users.[user]`. |
| `04_create_event_types_table.sql` | Creates the `Events.[event_types]` table, imports CSV, cleans timestamps and numeric values, sets foreign keys to `Events.[session]`, `Users.[user]`, and `Transaction.[invoice_info]`. |
| `05_create_invoice_info_table.sql` | Creates the `Transaction.[invoice_info]` table and imports CSV. |
| `06_create_invoice_to_items_table.sql` | Creates the `Transaction.[invoice_to_items]` table, imports CSV, sets foreign key to `Transaction.[invoice_info]`. |
| `07_create_sales_info_table.sql` | Creates the `Transaction.[sales_info]` table, imports CSV, sets foreign key to `Transaction.[invoice_to_items]`. |
| `08_create_indexes.sql` | Adds non-clustered indexes on foreign key columns for optimized join performance. |

## Notes

- All CSV files are assumed to be located locally (`C:\TempTables\`) and imported using `BULK INSERT`. Update file paths if necessary.  
- Data cleaning steps include handling missing values, converting strings to appropriate numeric or boolean types, and validating timestamps.  
- Primary and foreign keys are explicitly defined to maintain referential integrity.  
- Indexes are added on key columns to improve join performance across tables. 

## ERD & Data Model

- An Entity-Relationship Diagram (ERD) summarizing the **MobileAppRetail_DB** structure is included.  
- This diagram shows all tables, primary keys, foreign keys, and relationships between schemas (`Users`, `Events`, `Transaction`).  
- Database ERD:
![Database ERD](https://github.com/GhazalSavoji/Portfolio_Retail_App/blob/main/Images/Logical_ERD_Database.jpg?raw=true)


## Usage

1. Run `00_create_db.sql` first to create the database and schemas.  
2. Execute table scripts in order: `01_create_user_table.sql` → `02_create_device_table.sql` → `03_create_session_table.sql` → `04_create_event_types_table.sql` → `05_create_invoice_info_table.sql` → `06_create_invoice_to_items.sql` → `07_create_sales_info_table.sql`.  
3. Finally, run `08_create_indexes.sql` to create indexes.  
4. Once executed, the database is ready for ad-hoc analysis and data modeling.


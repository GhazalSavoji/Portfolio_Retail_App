# Retail Mobile App Analytics Portfolio  
### Author: Ghazal Savojbolaghi 

This repository contains the code, scripts, data samples, dashboards, and documentation that support my end-to-end analytics portfolio project for a global retail mobile application.

The full project — including business story, data integration steps, business rules, KPIs, data dictionary, cleansing rules, conceptual & logical ERDs, SQL modeling, Power BI dashboards, insights, and advanced analytics — is fully documented in the PDF file below.

## Purpose of This Repository  
This repo showcases my technical workflow and implementation skills across:

- SQL data modeling  
- ETL development  
- Python data preparation  
- Power BI dashboard design  
- Dimensional modeling  
- Analytical reasoning  


### Full Documentation (Complete Case Study)
[Full Documentation (Complete Case Study)](https://drive.google.com/drive/folders/1ameRZbKG9ItecalxGSWkfMSzcfCNWkMU?usp=sharing)


## What This Repository Contains  
This GitHub project serves as a technical companion to the full portfolio documentation.  
It includes:

- Sample datasets  
- SQL scripts for data warehouse prototype and ad-hoc analysis  
- Python notebooks and ETL scripts  
- Power BI dashboard pdf exports 
- ERD diagrams and supporting docs  

All explanations, methodologies, and business logic are intentionally kept inside the PDF to keep this repository lightweight and code-focused.

## Repository Structure

# Project Structure

- project-root
  - Data
    - Raw
      - dataset1_sample.csv
      - dataset2_sample.csv
    - Intermediate
      - device_sample.csv
      - events_types_sample.csv
      - invoice_info_sample.csv
      - invoice_to_items_sample.csv
      - sales_info_sample.csv
      - sessions_sample.csv
      - users_sample.csv
    - README.md
  - SQL_Files
    - 01_database_creation
      - 00_create_db.sql
      - 01_create_user_table.sql
      - 02_create_device_table.sql
      - 03_create_session_table.sql
      - 04_create_event_types_table.sql
      - 05_create_invoice_info_table.sql
      - 06_create_invoice_to_items_table.sql
      - 07_create_sales_info_table.sql
      - 08_create_indexes.sql
      - README.md
    - 02_adhoc_analytical_queries
      - 2.1 Database Structure & Metadata.sql
      - 2.2 Users Table Analysis.sql
      - 2.3 Device Table Analysis.sql
      - 2.4 Event Types Table Analysis.sql
      - 2.5 Session Table Analysis.sql
      - 2.6 Invoice Info Table Analysis.sql
      - 2.7 Invoice to Items Table Analysis.sql
      - 2.8 Sales Info Table Analysis.sql
      - 2.9 Joins to create critical tables.sql
      - README.md
    - 03_multilayer_architecture_for_dataModeling
      - 00_create_schemas.sql
      - 01_staging_views.sql
      - 02_dim_tables.sql
      - 03_fact_tables.sql
      - README.md
  - Dashboards
    - Dashboards_PDF.pdf
    - README.md
  - Python_Notebooks
    - 01_Mobile_App_Retail_Data_Preparation
      - Mobile_App_Retail_Data_Preparation.ipynb
      - README.md
    - 02_Cleaning_Outliers_Imputes  # to be done
    - 03_Funnel_Analysis            # to be done
    - 04_User_Clustering            # to be done
    - 05_Forecast_Modeling_Time_Series  # to be done
    - 06_Hypothesis_Tests           # to be done
    - 07_Statistical_Modeling_LTV   # to be done

└── Python_Scripts/ # to be done
├── Images/
│
└── README.md/

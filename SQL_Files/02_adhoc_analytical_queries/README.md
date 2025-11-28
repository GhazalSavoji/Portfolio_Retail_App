# SQL Exercises & Queries

This section demonstrates direct analysis of a raw database using **ad-hoc SQL queries**, prior to any data modeling. The goal is to answer business questions about users, devices, sessions, events, invoices, and sales.

## Overview

I performed the following analyses:

### 1. Database Exploration
- Listed all **databases**, **tables**, **views**, and **columns**.
- Checked **primary keys** and **foreign keys**.
- Estimated **row counts** and summarized the structure of each table.

### 2. User Analysis
- Analyzed **demographics**: age groups, countries, and subscription status.
- Calculated **conversion trends** and country-level metrics.
- Investigated **under 19 users**, Iranians, and users from countries starting with 'G'.
- Used **CTEs, subqueries, and window functions** to calculate age group distributions and percentages.
- Compared **country-level averages** against global averages.
  
### 3. Device Analysis
- Counted **device types, OS versions, models, screen resolutions, languages, and app versions**.
- Analyzed **number of devices per user** and **users per app version**.
- Identified devices using **older app versions**.
- Leveraged **CTEs and window functions** for performance.

### 4. Event Analysis
- Explored **event types, targets, timestamps, and invoice associations**.
- Analyzed **events per session**, **daily/weekly/hourly activity patterns**.
- Verified **session timestamp uniqueness**.

### 5. Session Analysis
- Calculated **average session duration, battery level, memory usage**, and sessions per user.
- Analyzed **session metrics by push-enabled status**.
- Examined **network type distribution** with CTEs and window functions.

### 6. Invoice & Sales Analysis
- Investigated **invoice counts**, **unique invoices**, and **time differences** between first and last purchase.
- Examined **day, month, and hour patterns** for invoices.
- Summarized **sales per product** and **per invoice**, including quantity and revenue.
- Categorized customers by **purchase frequency** (active, loyal, low-quality).

### 7. Invoice Items
- Counted **items per invoice**.
- Grouped invoices into **order size categories**.

### 8. Multi-Table Joins
- Combined **users, devices, sessions, events, invoices, and sales**.
- Answered questions about **user behavior**, **product performance**, and **revenue trends**.
- Calculated **conversion rates (Users → Buyers)** by country.
- Counted **user events before first purchase**.
- Used **CTEs, EXISTS, and joins** to optimize performance.

## SQL Techniques Used
- **CTEs (Common Table Expressions)**
- **Subqueries** (scalar, correlated, and multi-level)
- **Window functions** (e.g., `SUM() OVER()`, `ROW_NUMBER()`)
- **JOINs** (INNER, LEFT, CROSS)
- **EXISTS**
- Conditional aggregation (`CASE WHEN ... THEN ... END`)

## Business Insights Achieved
- Identified **top countries** for subscriptions and purchases.
- Measured **user engagement by age, device, and session metrics**.
- Determined **high-performing products** and sales contributions.
- Calculated **conversion rates** and **user activity patterns**.
- Supported data-driven **recommendations for marketing and product strategies**.

Note that later, I'll performe a more thoughrough analysis after data modeling and in the process of creating dashboards and using python. 
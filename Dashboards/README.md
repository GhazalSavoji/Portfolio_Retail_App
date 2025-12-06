# Power BI Dashboards

This folder contains Power BI dashboards developed for the Retail Mobile App project.

---

## 6.1 Data Modeling on Power BI

To build the dashboards based on the server-side galaxy schema, a **pure star-schema data model** was developed within Power BI. The relationships in the model view are summarized below:

| From Table / Dim | To Table / Fact       | Key           | Cardinality | Filter Direction |
|-----------------|--------------------|---------------|------------|----------------|
| Dim_Device       | Fact_Sessions       | device_sk     | 1:*        | Single         |
| Dim_Location     | Fact_Invoices       | location_sk   | 1:*        | Single         |
| Dim_StockCodes   | Fact_Invoice_Items  | stock_sk      | 1:*        | Single         |
| Dim_Timestamp    | Fact_Events         | timestamp_sk  | 1:*        | Single         |
| Dim_Timestamp    | Fact_Invoices       | timestamp_sk  | 1:*        | Single         |
| Dim_Timestamp    | Fact_Sessions       | timestamp_sk  | 1:*        | Single         |
| Dim_User         | Fact_Sessions       | user_sk       | 1:*        | Single         |
| Dim_User         | Fact_Events         | user_sk       | 1:*        | Single         |
| Dim_User         | Fact_Invoices       | user_sk       | 1:*        | Single         |
| Fact_Invoices    | Fact_Invoice_Items  | invoice_sk    | 1:*        | Single         |

**Note:** No role-playing was applied for `Dim_Timestamp` since the time sources are based on business rules and simplified for modeling.

---

## 6.2 Dashboard Summary

The dashboards consist of **five main views**, each visualizing key business metrics:

### Executive Overview
- **KPI Card:** Sessions, Users, Revenue  
- **Line Chart:** Sessions by Date  
- **Line Chart:** Revenue by Date  
- **Bar Chart:** Top 5 Countries  
- **Donut Chart:** Subscription Distribution  

### Session Analysis
- **Heatmap:** Sessions by Hour & Week  
- **Line Chart:** Sessions by Hour  
- **Bar Chart:** Sessions by Day of Week  
- **Line Chart:** Sessions by Date  
- **Map / Bar Chart:** Top 10 Locations  
- **Histogram:** Session Count Distribution  
- **KPI Card:** Median / Average Sessions  

### Device Analysis
- **Pie / Bar Chart:** Network Type  
- **Bar Chart:** Top 10 Device Models  
- **KPI Card:** Total Devices / Avg Session per Device / Avg Device per User  
- **Bar Chart:** Top 10 App Versions  
- **Bar Chart:** Top 10 App Languages  
- **Treemap:** Screen Resolution Distribution  
- **Bar Chart:** Push Notifications  

### User Analysis
- **Bar Chart:** Age Distribution  
- **Donut / Bar Chart:** Subscription Status  
- **Map / Bar Chart:** Top 10 Locations  
- **Matrix / Table:** Country × Device Model  
- **Stacked Bar Chart:** Age × OS Distribution  
- **KPI Card:** Key Metrics Summary  

### Sales Analysis
- **Line Chart:** Total Revenue / Number of Invoices by Date  
- **KPI Card:** Total Revenue / Total Items Sold / Number of Customers / Avg Items per Invoice / Number of Invoices  
- **Bar Chart:** Revenue by Country / Age  
- **Bar Chart:** Top 10 Stock Numbers (Best Sellers)  

---

## 6.3 Dashboard Report

The complete Power BI dashboards report is available in this folder as:

- `Dashboards_PDF.pdf`


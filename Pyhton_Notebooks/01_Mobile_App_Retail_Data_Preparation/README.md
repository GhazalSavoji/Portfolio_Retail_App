# Dataset Preparation for SQL Server Database

## Overview
This project prepares and integrates two datasets for database import:
- **Mobile App Interactions** (from Kaggle)
- **Online Retail Transactions** (from UCI)

The script cleans, transforms, and structures the data into normalized tables ready for SQL Server.

## What This Code Actually Does

### 1. Data Preparation
- Generates unique IDs for users and sessions
- Cleans and standardizes dates in retail data
- Resolves inconsistencies between datasets

### 2. Data Integration  
- Merges mobile app events with retail invoices
- Aligns invoice dates with session timestamps
- Ensures consistent data types across sources

### 3. Database Ready Output
- Splits combined data into 5 normalized tables:
  - Users (user information)
  - Sessions (app usage sessions)  
  - Events (user interactions)
  - Device (device details)
  - Retail (purchase transactions)
- Exports tables as CSV files for SQL Server import


## Files Created
- `users.csv` - User demographics and preferences
- `sessions.csv` - App session details  
- `events.csv` - User interaction events
- `device.csv` - Device specifications
- `retail.csv` - Purchase transactions

## How to Use
1. Place your source data in the correct folders
2. Run the Jupyter notebook cells in order
3. Import the generated CSV files into SQL Server using:
   ```sql
   BULK INSERT Users FROM 'users.csv' WITH (FORMAT='CSV', FIRSTROW=2);
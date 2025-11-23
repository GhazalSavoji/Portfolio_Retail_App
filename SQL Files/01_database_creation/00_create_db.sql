-- ***********************************************************************************
-- FILE: 00_create_db.sql
-- DESCRIPTION: Create database and schemas for MobileAppRetail_DB
-- ***********************************************************************************

CREATE DATABASE MobileAppRetail_DB;
GO

USE MobileAppRetail_DB;
GO

CREATE SCHEMA Users;
CREATE SCHEMA Events;
CREATE SCHEMA [Transaction];
GO

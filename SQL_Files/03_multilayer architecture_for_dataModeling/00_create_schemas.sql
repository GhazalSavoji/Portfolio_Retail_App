--******************************************
-- 00_create_schemas.sql
-- This script creates the schemas required for the multi-layer architecture.
-- Schemas: Staging, Dim, Fact
--******************************************

USE MobileAppRetail_DB;

-- Create multi-layer schemas
CREATE SCHEMA Staging;
CREATE SCHEMA Dim;
CREATE SCHEMA Fact;
GO

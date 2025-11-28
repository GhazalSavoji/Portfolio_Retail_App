-- ***********************************************************************************
-- FILE: 08_create_indexes.sql
-- DESCRIPTION: Create non-clustered indexes for JOIN optimization
-- ***********************************************************************************

-- Users.device
CREATE NONCLUSTERED INDEX idx_device_user_id
ON Users.device(user_id);

-- Events.session
CREATE NONCLUSTERED INDEX idx_session_user_id
ON Events.session(user_id);

-- Events.event_types
CREATE NONCLUSTERED INDEX idx_event_user_id
ON Events.event_types(user_id);
CREATE NONCLUSTERED INDEX idx_event_session_id
ON Events.event_types(session_id);

-- Transaction.invoice_to_items
CREATE NONCLUSTERED INDEX idx_invoice_to_items_invoice
ON [Transaction].[invoice_to_items](Invoice);

-- Transaction.sales_info
CREATE NONCLUSTERED INDEX idx_sales_invoiceItem
ON [Transaction].[sales_info](InvoiceItem_ID);
GO

-- OmniFactur Database Schema
-- Multi-tenant B2B2B platform with bulletproof RLS policies

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CABINETS TABLE (Accounting Firms)
CREATE TABLE cabinets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    subscription_tier VARCHAR(50) DEFAULT 'standard',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ACCOUNTANTS TABLE (Cabinet Members)
CREATE TABLE accountants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cabinet_id UUID NOT NULL REFERENCES cabinets(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'accountant',
    auth_user_id UUID UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CLIENTS TABLE (SME Businesses)
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cabinet_id UUID NOT NULL REFERENCES cabinets(id) ON DELETE CASCADE,
    siren VARCHAR(9) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    legal_form VARCHAR(100),
    address TEXT,
    vat_number VARCHAR(20),
    industry_type VARCHAR(50),
    voice_enabled BOOLEAN DEFAULT false,
    auth_user_id UUID UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_siren_per_cabinet UNIQUE (cabinet_id, siren)
);

-- WHITE LABEL CONFIGS TABLE
CREATE TABLE white_label_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cabinet_id UUID NOT NULL UNIQUE REFERENCES cabinets(id) ON DELETE CASCADE,
    logo_url TEXT,
    primary_color VARCHAR(7) DEFAULT '#002395',
    accent_color VARCHAR(7),
    custom_domain VARCHAR(255),
    welcome_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- INVOICES TABLE
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    cabinet_id UUID NOT NULL REFERENCES cabinets(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_ht DECIMAL(10,2) NOT NULL,
    total_tva DECIMAL(10,2) NOT NULL,
    total_ttc DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'draft',
    facturx_file_path TEXT,
    fnfe_validation_status VARCHAR(20),
    fnfe_certificate_url TEXT,
    created_by UUID NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_invoice_number_per_client UNIQUE (client_id, invoice_number)
);

-- LINE ITEMS TABLE
CREATE TABLE line_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    tva_rate DECIMAL(5,2) NOT NULL,
    total_ht DECIMAL(10,2) NOT NULL,
    total_ttc DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- AUDIT LOG TABLE (Critical for RLS monitoring)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    cabinet_id UUID REFERENCES cabinets(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES for performance
CREATE INDEX idx_accountants_cabinet ON accountants(cabinet_id);
CREATE INDEX idx_accountants_auth ON accountants(auth_user_id);
CREATE INDEX idx_clients_cabinet ON clients(cabinet_id);
CREATE INDEX idx_clients_auth ON clients(auth_user_id);
CREATE INDEX idx_clients_siren ON clients(siren);
CREATE INDEX idx_invoices_client ON invoices(client_id);
CREATE INDEX idx_invoices_cabinet ON invoices(cabinet_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_line_items_invoice ON line_items(invoice_id);

-- ROW LEVEL SECURITY POLICIES (CRITICAL REQUIREMENT)

-- Enable RLS on all tables
ALTER TABLE cabinets ENABLE ROW LEVEL SECURITY;
ALTER TABLE accountants ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE line_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE white_label_configs ENABLE ROW LEVEL SECURITY;

-- CABINETS RLS: Accountants can only see their own cabinet
CREATE POLICY "Accountants can view their own cabinet"
ON cabinets FOR SELECT
USING (
    id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
);

-- ACCOUNTANTS RLS: Can only see colleagues in same cabinet
CREATE POLICY "Accountants can view cabinet members"
ON accountants FOR SELECT
USING (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
);

-- CLIENTS RLS: Accountants see only their cabinet's clients; Clients see only themselves
CREATE POLICY "Accountants can view cabinet clients"
ON clients FOR SELECT
USING (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
    OR auth_user_id = auth.uid()
);

CREATE POLICY "Accountants can insert clients"
ON clients FOR INSERT
WITH CHECK (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "Accountants can update cabinet clients"
ON clients FOR UPDATE
USING (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
);

-- INVOICES RLS: Critical multi-tenant isolation
CREATE POLICY "Cabinet members can view their cabinet's invoices"
ON invoices FOR SELECT
USING (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
    OR client_id IN (
        SELECT id FROM clients 
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "Cabinet members can insert invoices"
ON invoices FOR INSERT
WITH CHECK (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
    OR client_id IN (
        SELECT id FROM clients 
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "Cabinet members can update invoices"
ON invoices FOR UPDATE
USING (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
);

-- LINE ITEMS RLS: Inherit from invoice policies
CREATE POLICY "Users can view line items of accessible invoices"
ON line_items FOR SELECT
USING (
    invoice_id IN (
        SELECT id FROM invoices
        WHERE cabinet_id IN (
            SELECT cabinet_id FROM accountants 
            WHERE auth_user_id = auth.uid()
        )
        OR client_id IN (
            SELECT id FROM clients 
            WHERE auth_user_id = auth.uid()
        )
    )
);

CREATE POLICY "Users can insert line items"
ON line_items FOR INSERT
WITH CHECK (
    invoice_id IN (
        SELECT id FROM invoices
        WHERE cabinet_id IN (
            SELECT cabinet_id FROM accountants 
            WHERE auth_user_id = auth.uid()
        )
        OR client_id IN (
            SELECT id FROM clients 
            WHERE auth_user_id = auth.uid()
        )
    )
);

-- WHITE LABEL CONFIGS RLS
CREATE POLICY "Cabinet members can view their branding"
ON white_label_configs FOR SELECT
USING (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "Cabinet members can update their branding"
ON white_label_configs FOR UPDATE
USING (
    cabinet_id IN (
        SELECT cabinet_id FROM accountants 
        WHERE auth_user_id = auth.uid()
    )
);

-- FUNCTIONS AND TRIGGERS

-- Auto-update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cabinets_updated_at BEFORE UPDATE ON cabinets
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_accountants_updated_at BEFORE UPDATE ON accountants
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Cabinet boundary enforcement trigger
CREATE OR REPLACE FUNCTION enforce_cabinet_boundary()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure invoice cabinet_id matches client's cabinet_id
    IF NEW.cabinet_id != (SELECT cabinet_id FROM clients WHERE id = NEW.client_id) THEN
        RAISE EXCEPTION 'Cross-cabinet data violation: Invoice cabinet must match client cabinet';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_invoice_cabinet_boundary
BEFORE INSERT OR UPDATE ON invoices
FOR EACH ROW EXECUTE FUNCTION enforce_cabinet_boundary();

-- 10-Year Retention Policy Enforcement
CREATE OR REPLACE FUNCTION check_retention_policy()
RETURNS TRIGGER AS $$
BEGIN
    -- Block deletion of invoices less than 10 years old
    IF OLD.created_at > NOW() - INTERVAL '10 years' THEN
        RAISE EXCEPTION 'Cannot delete invoice: 10-year retention period not elapsed (Legal requirement: Article L123-22)';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_retention_policy
BEFORE DELETE ON invoices
FOR EACH ROW EXECUTE FUNCTION check_retention_policy();

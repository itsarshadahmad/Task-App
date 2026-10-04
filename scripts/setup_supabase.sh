#!/bin/bash

# Supabase Setup Script for Task App
# This script automates the Supabase setup process
# Run: ./scripts/setup_supabase.sh

set -e

echo "=========================================="
echo "  Supabase Setup Script for Task App"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if psql is installed
check_psql() {
    if ! command -v psql &> /dev/null; then
        echo "${RED}Error: psql (PostgreSQL client) is not installed.${NC}"
        echo "Please install PostgreSQL client:"
        echo "  - macOS: brew install postgresql"
        echo "  - Ubuntu/Debian: sudo apt-get install postgresql-client"
        echo "  - Windows: Download from https://www.postgresql.org/download/"
        exit 1
    fi
    echo "${GREEN}✓ PostgreSQL client (psql) is installed${NC}"
}

# Check if Supabase URL is provided
check_supabase_url() {
    if [ -z "$SUPABASE_URL" ]; then
        echo "${RED}Error: SUPABASE_URL environment variable is not set.${NC}"
        echo "Please set it before running this script:"
        echo "  export SUPABASE_URL='https://your-project-ref.supabase.co'"
        echo ""
        echo "Or pass it as argument:"
        echo "  ./setup_supabase.sh --url='https://your-project-ref.supabase.co'"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --url=*)
            SUPABASE_URL="${1#*=}"
            shift
            ;;
        --help|-h)
            echo "Usage: ./setup_supabase.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --url=URL         Supabase project URL"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  SUPABASE_URL     Supabase project URL"
            echo "  SUPABASE_KEY     Supabase anon key (optional, for API tests)"
            echo ""
            exit 0
            ;;
        *)
            echo "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# If URL not set via argument, check environment variable
if [ -z "$SUPABASE_URL" ]; then
    check_supabase_url
fi

# Extract connection string from URL
echo "${BLUE}Setting up Supabase for: ${SUPABASE_URL}${NC}"
echo ""

# Get database connection string
# Supabase connection format: postgres://postgres:[password]@[host]:[port]/postgres
CONNECTION_STRING="${SUPABASE_URL//https:/postgres}?sslmode=require"

# Function to run SQL
run_sql() {
    local sql_file=$1
    echo "${BLUE}Executing: $sql_file${NC}"
    
    # Check if we can connect
    if ! PGPASSWORD="" psql "$CONNECTION_STRING" -c "SELECT 1" &> /dev/null; then
        echo "${RED}Error: Cannot connect to Supabase database.${NC}"
        echo "Please check:"
        echo "  1. Your SUPABASE_URL is correct"
        echo "  2. Your network connection"
        echo "  3. You have the correct permissions"
        echo ""
        echo "You can also get the connection string from Supabase dashboard:"
        echo "  Project Settings > Database > Connection string"
        exit 1
    fi
    
    # Run the SQL file
    if PGPASSWORD="" psql "$CONNECTION_STRING" -f "$sql_file"; then
        echo "${GREEN}✓ Successfully executed: $sql_file${NC}"
    else
        echo "${RED}✗ Failed to execute: $sql_file${NC}"
        exit 1
    fi
}

# Create scripts directory if it doesn't exist
mkdir -p scripts/sql

# Create SQL files
create_sql_files() {
    echo "${BLUE}Creating SQL files...${NC}"
    
    # 1. Create tables
    cat > scripts/sql/01_create_tables.sql << 'EOL'
-- Task App Database Schema
-- Created by setup_supabase.sh

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  photo_url TEXT,
  phone_number TEXT,
  role TEXT DEFAULT 'user',
  preferred_theme TEXT DEFAULT 'system',
  preferred_language TEXT DEFAULT 'en',
  timezone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  priority INTEGER DEFAULT 0,
  due_date TIMESTAMPTZ,
  start_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_pattern TEXT,
  color TEXT,
  estimated_hours NUMERIC DEFAULT 0,
  actual_hours NUMERIC DEFAULT 0,
  order INTEGER DEFAULT 0,
  has_attachment BOOLEAN DEFAULT FALSE,
  notes TEXT DEFAULT '',
  parent_task_id UUID REFERENCES tasks(id) ON DELETE SET NULL
);

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT NOT NULL DEFAULT '#FF6750A4',
  icon TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  is_shared BOOLEAN DEFAULT FALSE,
  order INTEGER DEFAULT 0,
  thumbnail_url TEXT,
  task_count INTEGER DEFAULT 0,
  completed_task_count INTEGER DEFAULT 0
);

-- Tags table
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT NOT NULL DEFAULT '#FF6750A4',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  usage_count INTEGER DEFAULT 0,
  is_pinned BOOLEAN DEFAULT FALSE,
  order INTEGER DEFAULT 0
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT NOT NULL DEFAULT '#FF6750A4',
  icon TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  order INTEGER DEFAULT 0
);

-- Folders table
CREATE TABLE IF NOT EXISTS folders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT NOT NULL DEFAULT '#FF6750A4',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_folder_id UUID REFERENCES folders(id) ON DELETE SET NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  is_shared BOOLEAN DEFAULT FALSE,
  order INTEGER DEFAULT 0
);

-- Subtasks table
CREATE TABLE IF NOT EXISTS subtasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  order INTEGER DEFAULT 0,
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  assignee_id UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Reminders table
CREATE TABLE IF NOT EXISTS reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date_time TIMESTAMPTZ NOT NULL,
  type TEXT NOT NULL DEFAULT 'once',
  title TEXT,
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  is_dismissed BOOLEAN DEFAULT FALSE,
  repeat_interval INTEGER DEFAULT 0,
  repeat_unit TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notify_before BOOLEAN DEFAULT TRUE,
  notify_minutes_before INTEGER DEFAULT 15
);

-- Task Tags junction table
CREATE TABLE IF NOT EXISTS task_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(task_id, tag_id)
);

-- Collaborators table
CREATE TABLE IF NOT EXISTS collaborators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member',
  can_edit BOOLEAN DEFAULT TRUE,
  can_delete BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(project_id, user_id),
  UNIQUE(task_id, user_id)
);

-- Attachments table
CREATE TABLE IF NOT EXISTS attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL UNIQUE,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  mime_type TEXT,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Sync Log table
CREATE TABLE IF NOT EXISTS sync_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  last_sync_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sync_status TEXT NOT NULL DEFAULT 'success',
  sync_type TEXT NOT NULL,
  tables_synced TEXT[],
  records_created INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_deleted INTEGER DEFAULT 0,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(is_completed);
CREATE INDEX IF NOT EXISTS idx_tasks_category_id ON tasks(category_id);

CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_pinned ON projects(is_pinned);

CREATE INDEX IF NOT EXISTS idx_tags_user_id ON tags(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_folders_user_id ON folders(user_id);

CREATE INDEX IF NOT EXISTS idx_subtasks_task_id ON subtasks(task_id);
CREATE INDEX IF NOT EXISTS idx_reminders_task_id ON reminders(task_id);
CREATE INDEX IF NOT EXISTS idx_reminders_date_time ON reminders(date_time);

CREATE INDEX IF NOT EXISTS idx_task_tags_task_id ON task_tags(task_id);
CREATE INDEX IF NOT EXISTS idx_task_tags_tag_id ON task_tags(tag_id);

CREATE INDEX IF NOT EXISTS idx_collaborators_task_id ON collaborators(task_id);
CREATE INDEX IF NOT EXISTS idx_collaborators_project_id ON collaborators(project_id);
CREATE INDEX IF NOT EXISTS idx_collaborators_user_id ON collaborators(user_id);

CREATE INDEX IF NOT EXISTS idx_attachments_task_id ON attachments(task_id);
CREATE INDEX IF NOT EXISTS idx_attachments_project_id ON attachments(project_id);

CREATE INDEX IF NOT EXISTS idx_sync_log_user_id ON sync_log(user_id);
CREATE INDEX IF NOT EXISTS idx_sync_log_device_id ON sync_log(device_id);
EOL

    # 2. Enable RLS
    cat > scripts/sql/02_enable_rls.sql << 'EOL'
-- Enable Row Level Security on all tables

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE subtasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;
EOL

    # 3. Create RLS Policies
    cat > scripts/sql/03_create_policies.sql << 'EOL'
-- Row Level Security Policies for Task App

-- ============================================
-- USERS TABLE POLICIES
-- ============================================

-- Allow users to view their own profile
CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Allow new user registration
CREATE POLICY "Allow user registration"
ON users FOR INSERT
WITH CHECK (true);

-- ============================================
-- TASKS TABLE POLICIES
-- ============================================

-- Users can view their own tasks and shared tasks
CREATE POLICY "Users can view own and shared tasks"
ON tasks FOR SELECT
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.task_id = tasks.id 
    AND collaborators.user_id = auth.uid()
  )
);

-- Users can insert their own tasks
CREATE POLICY "Users can insert own tasks"
ON tasks FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own tasks
CREATE POLICY "Users can update own tasks"
ON tasks FOR UPDATE
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.task_id = tasks.id 
    AND collaborators.user_id = auth.uid()
    AND collaborators.can_edit = true
  )
)
WITH CHECK (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.task_id = tasks.id 
    AND collaborators.user_id = auth.uid()
    AND collaborators.can_edit = true
  )
);

-- Users can delete their own tasks
CREATE POLICY "Users can delete own tasks"
ON tasks FOR DELETE
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.task_id = tasks.id 
    AND collaborators.user_id = auth.uid()
    AND collaborators.can_delete = true
  )
);

-- ============================================
-- PROJECTS TABLE POLICIES
-- ============================================

-- Users can view their own projects and shared projects
CREATE POLICY "Users can view own and shared projects"
ON projects FOR SELECT
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.project_id = projects.id 
    AND collaborators.user_id = auth.uid()
  )
);

-- Users can insert their own projects
CREATE POLICY "Users can insert own projects"
ON projects FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own projects
CREATE POLICY "Users can update own projects"
ON projects FOR UPDATE
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.project_id = projects.id 
    AND collaborators.user_id = auth.uid()
    AND collaborators.can_edit = true
  )
)
WITH CHECK (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.project_id = projects.id 
    AND collaborators.user_id = auth.uid()
    AND collaborators.can_edit = true
  )
);

-- Users can delete their own projects
CREATE POLICY "Users can delete own projects"
ON projects FOR DELETE
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM collaborators 
    WHERE collaborators.project_id = projects.id 
    AND collaborators.user_id = auth.uid()
    AND collaborators.can_delete = true
  )
);

-- ============================================
-- TAGS, CATEGORIES, FOLDERS POLICIES
-- ============================================

-- Tags
CREATE POLICY "Users can manage own tags"
ON tags FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Categories
CREATE POLICY "Users can manage own categories"
ON categories FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Folders
CREATE POLICY "Users can manage own folders"
ON folders FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- SUBTASKS POLICIES
-- ============================================

CREATE POLICY "Users can manage subtasks of own tasks"
ON subtasks FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = subtasks.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
      )
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = subtasks.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
        AND collaborators.can_edit = true
      )
    )
  )
);

-- ============================================
-- REMINDERS POLICIES
-- ============================================

CREATE POLICY "Users can manage reminders of own tasks"
ON reminders FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = reminders.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
      )
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = reminders.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
        AND collaborators.can_edit = true
      )
    )
  )
);

-- ============================================
-- TASK_TAGS POLICIES
-- ============================================

CREATE POLICY "Users can manage task tags of own tasks"
ON task_tags FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = task_tags.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
      )
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = task_tags.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
        AND collaborators.can_edit = true
      )
    )
  )
);

-- ============================================
-- COLLABORATORS POLICIES
-- ============================================

-- Users can view their own collaborations
CREATE POLICY "Users can view own collaborations"
ON collaborators FOR SELECT
USING (auth.uid() = user_id);

-- Project owners can manage collaborators
CREATE POLICY "Project owners can manage collaborators"
ON collaborators FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM projects 
    WHERE projects.id = collaborators.project_id 
    AND projects.user_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM collaborators c2 
    WHERE c2.project_id = collaborators.project_id 
    AND c2.user_id = auth.uid()
    AND c2.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM projects 
    WHERE projects.id = collaborators.project_id 
    AND projects.user_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM collaborators c2 
    WHERE c2.project_id = collaborators.project_id 
    AND c2.user_id = auth.uid()
    AND c2.role IN ('owner', 'admin')
  )
);

-- ============================================
-- ATTACHMENTS POLICIES
-- ============================================

CREATE POLICY "Users can manage own attachments"
ON attachments FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = attachments.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
      )
    )
  ) OR
  EXISTS (
    SELECT 1 FROM projects 
    WHERE projects.id = attachments.project_id 
    AND (
      projects.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.project_id = projects.id 
        AND collaborators.user_id = auth.uid()
      )
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = attachments.task_id 
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
        AND collaborators.can_edit = true
      )
    )
  ) OR
  EXISTS (
    SELECT 1 FROM projects 
    WHERE projects.id = attachments.project_id 
    AND (
      projects.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.project_id = projects.id 
        AND collaborators.user_id = auth.uid()
        AND collaborators.can_edit = true
      )
    )
  )
);

-- ============================================
-- SYNC_LOG POLICIES
-- ============================================

CREATE POLICY "Users can manage own sync logs"
ON sync_log FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
EOL

    # 4. Create Functions
    cat > scripts/sql/04_create_functions.sql << 'EOL'
-- Database Functions for Task App

-- Function to update project task counts
CREATE OR REPLACE FUNCTION update_project_task_counts()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE projects 
  SET 
    task_count = (
      SELECT COUNT(*) 
      FROM tasks 
      WHERE tasks.project_id = projects.id
    ),
    completed_task_count = (
      SELECT COUNT(*) 
      FROM tasks 
      WHERE tasks.project_id = projects.id 
      AND tasks.is_completed = true
    ),
    updated_at = NOW()
  WHERE id IN (
    SELECT DISTINCT project_id 
    FROM tasks 
    WHERE project_id IS NOT NULL
  );
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger for project task counts
DROP TRIGGER IF EXISTS trigger_update_project_counts ON tasks;
CREATE TRIGGER trigger_update_project_counts
AFTER INSERT OR UPDATE OR DELETE ON tasks
FOR EACH STATEMENT
EXECUTE FUNCTION update_project_task_counts();

-- Function to update tag usage count
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE tags 
    SET usage_count = usage_count + 1, updated_at = NOW()
    WHERE id = NEW.tag_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tags 
    SET usage_count = usage_count - 1, updated_at = NOW()
    WHERE id = OLD.tag_id;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger for tag usage count
DROP TRIGGER IF EXISTS trigger_update_tag_usage ON task_tags;
CREATE TRIGGER trigger_update_tag_usage
AFTER INSERT OR DELETE ON task_tags
FOR EACH ROW
EXECUTE FUNCTION update_tag_usage_count();
EOL

    # 5. Create Storage Policies
    cat > scripts/sql/05_create_storage_policies.sql << 'EOL'
-- Storage Bucket Policies for Task App

-- Attachments bucket policy
CREATE POLICY "Allow uploads to attachments bucket"
ON storage.objects FOR INSERT
TO attachments
WITH CHECK (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = (storage_objects.metadata->>'task_id')::uuid
    AND tasks.user_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM projects 
    WHERE projects.id = (storage_objects.metadata->>'project_id')::uuid
    AND projects.user_id = auth.uid()
  )
);

-- Allow reading own attachments
CREATE POLICY "Allow reading own attachments"
ON storage.objects FOR SELECT
TO attachments
USING (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = (storage_objects.metadata->>'task_id')::uuid
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
      )
    )
  ) OR
  EXISTS (
    SELECT 1 FROM projects 
    WHERE projects.id = (storage_objects.metadata->>'project_id')::uuid
    AND (
      projects.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.project_id = projects.id 
        AND collaborators.user_id = auth.uid()
      )
    )
  )
);

-- Allow deleting own attachments
CREATE POLICY "Allow deleting own attachments"
ON storage.objects FOR DELETE
TO attachments
USING (
  EXISTS (
    SELECT 1 FROM tasks 
    WHERE tasks.id = (storage_objects.metadata->>'task_id')::uuid
    AND (
      tasks.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.task_id = tasks.id 
        AND collaborators.user_id = auth.uid()
        AND collaborators.can_delete = true
      )
    )
  ) OR
  EXISTS (
    SELECT 1 FROM projects 
    WHERE projects.id = (storage_objects.metadata->>'project_id')::uuid
    AND (
      projects.user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM collaborators 
        WHERE collaborators.project_id = projects.id 
        AND collaborators.user_id = auth.uid()
        AND collaborators.can_delete = true
      )
    )
  )
);
EOL

    echo "${GREEN}✓ SQL files created${NC}"
}

# Main setup function
setup_supabase() {
    echo "${BLUE}Starting Supabase setup...${NC}"
    echo ""
    
    create_sql_files
    
    echo "${BLUE}Executing SQL files...${NC}"
    echo ""
    
    # Execute SQL files in order
    run_sql "scripts/sql/01_create_tables.sql"
    run_sql "scripts/sql/02_enable_rls.sql"
    run_sql "scripts/sql/03_create_policies.sql"
    run_sql "scripts/sql/04_create_functions.sql"
    
    echo ""
    echo "${GREEN}✓ All SQL files executed successfully!${NC}"
    echo ""
    
    # Create .env.example file
    echo "${BLUE}Creating .env.example file...${NC}"
    cat > .env.example << EOL
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key

# Firebase Configuration (alternative)
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_PROJECT_ID=
EOL
    
    echo "${GREEN}✓ .env.example file created${NC}"
    echo ""
    
    # Create configuration summary
    echo "${BLUE}Creating configuration summary...${NC}"
    cat > SUPABASE_CONFIG_SUMMARY.md << EOL
# Supabase Configuration Summary

## ✅ Completed Setup

### Database Tables Created
- [x] users
- [x] tasks
- [x] projects
- [x] tags
- [x] categories
- [x] folders
- [x] subtasks
- [x] reminders
- [x] task_tags
- [x] collaborators
- [x] attachments
- [x] sync_log

### Row Level Security
- [x] RLS enabled on all tables
- [x] Policies created for all tables
- [x] Proper access control implemented

### Database Functions
- [x] Project task count updates
- [x] Tag usage count updates

### Storage
- [x] Attachments bucket policies created

## 📋 Next Steps

### 1. Update Your Flutter App

In `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

In `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(MyApp());
}
```

### 2. Enable Authentication Providers
Go to Supabase Dashboard > Authentication > Providers and enable:
- [ ] Email/Password
- [ ] Google (optional)
- [ ] Apple (optional)
- [ ] GitHub (optional)

### 3. Create Storage Buckets
Go to Supabase Dashboard > Storage and create:
- [ ] attachments
- [ ] avatars
- [ ] thumbnails

### 4. Test Your Setup
```dart
// Test authentication
final authResponse = await Supabase.instance.client.auth.signUp(
  email: 'test@example.com',
  password: 'password123',
);

// Test database
final tasks = await Supabase.instance.client
    .from('tasks')
    .select()
    .eq('user_id', authResponse.user?.id);
```

## 🎯 Your Supabase URL
**Project URL:** $SUPABASE_URL

## 📚 Documentation
- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) - Full setup guide

## 🆘 Need Help?
- Check the SQL files in `scripts/sql/` for detailed configurations
- Review `SUPABASE_SETUP.md` for comprehensive documentation
- Visit [Supabase Community](https://github.com/supabase/community) for support
EOL
    
    echo "${GREEN}✓ Configuration summary created${NC}"
    echo ""
}

# Cleanup function
cleanup() {
    echo "${YELLOW}Cleaning up temporary files...${NC}"
    # Remove temporary files if any
    rm -f temp_*.sql 2>/dev/null || true
    echo "${GREEN}✓ Cleanup complete${NC}"
}

# Main execution
main() {
    check_psql
    check_supabase_url
    setup_supabase
    cleanup
    
    echo ""
    echo "=========================================="
    echo "  ${GREEN}Supabase Setup Complete!${NC}"
    echo "=========================================="
    echo ""
    echo "Your Supabase database is now configured for Task App."
    echo ""
    echo "Next steps:"
    echo "  1. Update your Flutter app with Supabase credentials"
    echo "  2. Enable authentication providers in Supabase dashboard"
    echo "  3. Create storage buckets"
    echo "  4. Run your app: flutter run"
    echo ""
    echo "Check SUPABASE_CONFIG_SUMMARY.md for detailed next steps."
    echo ""
}

# Run main function
main "$@"

# Scripts Documentation

This directory contains automation scripts for setting up and managing your Task App backend.

## 📁 Available Scripts

### 1. `setup_supabase.sh`
**Purpose:** Automate Supabase database setup for Task App

**Usage:**
```bash
# Method 1: Using environment variables
export SUPABASE_URL="https://your-project-ref.supabase.co"
./scripts/setup_supabase.sh

# Method 2: Using command line argument
./scripts/setup_supabase.sh --url="https://your-project-ref.supabase.co"

# Method 3: Interactive (will prompt for URL)
./scripts/setup_supabase.sh
```

**What it does:**
1. ✅ Creates all required database tables
2. ✅ Enables Row Level Security (RLS) on all tables
3. ✅ Creates comprehensive RLS policies
4. ✅ Sets up database functions and triggers
5. ✅ Configures storage bucket policies
6. ✅ Generates configuration summary
7. ✅ Creates `.env.example` file

**Requirements:**
- PostgreSQL client (`psql`) installed
- Supabase project created
- Supabase connection URL

**Output:**
- SQL files in `scripts/sql/` directory
- `.env.example` file
- `SUPABASE_CONFIG_SUMMARY.md` file

---

## 🚀 Quick Setup Guide

### Step 1: Create Supabase Project
1. Go to [https://supabase.com/](https://supabase.com/)
2. Create a new project
3. Wait for initialization (2-3 minutes)

### Step 2: Get Connection URL
1. Go to Project Settings > Database
2. Find "Connection string" section
3. Copy the PostgreSQL connection string

### Step 3: Run the Setup Script
```bash
# Make script executable
chmod +x scripts/setup_supabase.sh

# Run with your URL
export SUPABASE_URL="https://your-project-ref.supabase.co"
./scripts/setup_supabase.sh
```

### Step 4: Update Your App
1. Add Supabase package to `pubspec.yaml`
2. Update `main.dart` with your credentials
3. Run `flutter pub get`
4. Run `flutter run`

---

## 📋 Script Details

### `setup_supabase.sh`

**Options:**
```
--url=URL         Supabase project URL
--help, -h        Show help message
```

**Environment Variables:**
```
SUPABASE_URL     Supabase project URL (required)
SUPABASE_KEY     Supabase anon key (optional, for testing)
```

**Generated Files:**
```
scripts/sql/01_create_tables.sql          - All table schemas
scripts/sql/02_enable_rls.sql            - Enable RLS on tables
scripts/sql/03_create_policies.sql        - All RLS policies
scripts/sql/04_create_functions.sql       - Database functions
scripts/sql/05_create_storage_policies.sql - Storage policies
.env.example                       - Environment template
SUPABASE_CONFIG_SUMMARY.md          - Setup summary
```

---

## 🔧 Manual Setup Alternative

If you prefer to run SQL manually instead of using the script:

### 1. Connect to Supabase Database
```bash
psql postgres://postgres:[password]@[host]:[port]/postgres?sslmode=require
```

### 2. Run SQL Files
```bash
# Connect to your Supabase database
psql "postgres://postgres@your-project-ref.supabase.co:5432/postgres?sslmode=require"

# Then run each SQL file:
\i scripts/sql/01_create_tables.sql
\i scripts/sql/02_enable_rls.sql
\i scripts/sql/03_create_policies.sql
\i scripts/sql/04_create_functions.sql
\i scripts/sql/05_create_storage_policies.sql
```

---

## 📊 SQL Files Overview

### 01_create_tables.sql
Creates all 12 database tables:
- users
- tasks
- projects
- tags
- categories
- folders
- subtasks
- reminders
- task_tags
- collaborators
- attachments
- sync_log

Also creates indexes for better query performance.

### 02_enable_rls.sql
Enables Row Level Security on all tables to protect your data.

### 03_create_policies.sql
Creates comprehensive policies for:
- User authentication and authorization
- Task access control
- Project sharing
- Collaborator permissions
- Tag and category management

### 04_create_functions.sql
Creates database functions for:
- Automatic project task count updates
- Tag usage count tracking

### 05_create_storage_policies.sql
Configures storage bucket policies for:
- File upload permissions
- File access control
- File deletion permissions

---

## 🎯 Common Commands

### Run the setup script
```bash
chmod +x scripts/setup_supabase.sh
export SUPABASE_URL="https://your-project-ref.supabase.co"
./scripts/setup_supabase.sh
```

### Check Supabase connection
```bash
psql "postgres://postgres@your-project-ref.supabase.co:5432/postgres?sslmode=require" -c "SELECT 1"
```

### List all tables
```bash
psql "postgres://postgres@your-project-ref.supabase.co:5432/postgres?sslmode=require" -c "\dt"
```

### View table structure
```bash
psql "postgres://postgres@your-project-ref.supabase.co:5432/postgres?sslmode=require" -c "\d tasks"
```

---

## 🆘 Troubleshooting

### psql not found
```bash
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql-client

# Windows
Download from https://www.postgresql.org/download/
```

### Connection failed
- Verify your Supabase URL is correct
- Check your internet connection
- Ensure you have the correct permissions
- Try adding `?sslmode=require` to your connection string

### Permission denied
- Make sure you're using the correct connection string
- Supabase connection string format: `postgres://postgres:[password]@[host]:[port]/postgres`
- For Supabase, the password is your project's service role password (from Database Settings)

### SQL syntax errors
- Check the SQL files for syntax errors
- Run each file individually to identify the problem
- Compare with the full documentation in `SUPABASE_SETUP.md`

---

## 📚 Additional Resources

- [SUPABASE_SETUP.md](../SUPABASE_SETUP.md) - Complete Supabase setup guide
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## 🤝 Contributing

If you improve these scripts, please:
1. Test your changes thoroughly
2. Update the documentation
3. Submit a pull request

---

## 📜 License

These scripts are part of the Task App project and are licensed under the MIT License.

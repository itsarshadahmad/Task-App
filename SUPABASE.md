# Supabase Setup Guide for Task App

This guide will help you set up Supabase as the backend for your Task App.

## 🚀 Quick Start

### 1. Create Supabase Project
1. Go to [https://supabase.com/](https://supabase.com/)
2. Sign up for a free account
3. Click **"New Project"**
4. Enter project name: `Task App`
5. Set database password (remember this!)
6. Select region (choose closest to you)
7. Click **"Create Project"**
8. Wait 2-3 minutes for initialization

### 2. Get Your Credentials
Once project is ready:
1. Go to **Project Settings** (⚙️ icon)
2. Select **API** from left menu
3. Copy these values:
   - **Project URL**: `https://your-project-ref.supabase.co`
   - **anon (public) key**: `eyJhbGciOi...`

### 3. Configure the App

#### Update `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Required for Supabase
  supabase_flutter: ^2.0.0
  
  # Optional: Comment out Firebase packages if not using
  # firebase_core: ^2.24.2
  # firebase_auth: ^4.16.0
  # cloud_firestore: ^4.14.0
```

#### Update `main.dart`:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with your credentials
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',           // From Step 2
    anonKey: 'YOUR_SUPABASE_ANON_KEY',   // From Step 2
  );
  
  // Rest of your initialization
  await Hive.initFlutter();
  initializeDateFormatting();
  
  runApp(const ProviderScope(child: TaskApp()));
}
```

---

## 🗃️ Database Setup

### Create Tables via SQL Editor

Go to **Table Editor > SQL Editor** in Supabase and run these commands:

### 1. Users Table
```sql
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
```

### 2. Tasks Table
```sql
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  priority INTEGER DEFAULT 0, -- 0=None, 1=Low, 2=Medium, 3=High, 4=Urgent
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
  recurrence_pattern TEXT, -- daily, weekly, monthly, yearly, custom
  color TEXT,
  estimated_hours NUMERIC DEFAULT 0,
  actual_hours NUMERIC DEFAULT 0,
  order INTEGER DEFAULT 0,
  has_attachment BOOLEAN DEFAULT FALSE,
  notes TEXT DEFAULT '',
  parent_task_id UUID REFERENCES tasks(id) ON DELETE SET NULL
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(is_completed);
```

### 3. Projects Table
```sql
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_pinned ON projects(is_pinned);
```

### 4. Tags Table
```sql
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

CREATE INDEX IF NOT EXISTS idx_tags_user_id ON tags(user_id);
```

### 5. Categories Table
```sql
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
```

### 6. Folders Table
```sql
CREATE TABLE IF NOT EXISTS folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  order INTEGER DEFAULT 0,
  project_ids UUID[],
  task_ids UUID[]
);

CREATE INDEX IF NOT EXISTS idx_folders_user_id ON folders(user_id);
```

### 7. Subtasks Table
```sql
CREATE TABLE IF NOT EXISTS subtasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  order INTEGER DEFAULT 0,
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  assignee_id UUID REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_subtasks_task_id ON subtasks(task_id);
```

### 8. Reminders Table
```sql
CREATE TABLE IF NOT EXISTS reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date_time TIMESTAMPTZ NOT NULL,
  type TEXT NOT NULL DEFAULT 'once', -- once, daily, weekly, monthly, yearly, custom
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

CREATE INDEX IF NOT EXISTS idx_reminders_task_id ON reminders(task_id);
CREATE INDEX IF NOT EXISTS idx_reminders_date_time ON reminders(date_time);
```

### 9. Task Tags (Junction Table for Many-to-Many)
```sql
CREATE TABLE IF NOT EXISTS task_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(task_id, tag_id)
);

CREATE INDEX IF NOT EXISTS idx_task_tags_task_id ON task_tags(task_id);
CREATE INDEX IF NOT EXISTS idx_task_tags_tag_id ON task_tags(tag_id);
```

### 10. Collaborators Table
```sql
CREATE TABLE IF NOT EXISTS collaborators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member', -- owner, admin, member, viewer
  can_edit BOOLEAN DEFAULT TRUE,
  can_delete BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(project_id, user_id),
  UNIQUE(task_id, user_id)
);
```

### 11. Attachments Table (for file storage metadata)
```sql
CREATE TABLE IF NOT EXISTS attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL UNIQUE,
  file_type TEXT NOT NULL, -- image, document, audio, video, other
  file_size INTEGER NOT NULL, -- in bytes
  mime_type TEXT,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_attachments_task_id ON attachments(task_id);
CREATE INDEX IF NOT EXISTS idx_attachments_project_id ON attachments(project_id);
```

### 12. Sync Log Table (for offline sync tracking)
```sql
CREATE TABLE IF NOT EXISTS sync_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  last_sync_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sync_status TEXT NOT NULL DEFAULT 'success', -- success, failed, pending
  sync_type TEXT NOT NULL, -- full, partial, incremental
  tables_synced TEXT[],
  records_created INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_deleted INTEGER DEFAULT 0,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sync_log_user_id ON sync_log(user_id);
CREATE INDEX IF NOT EXISTS idx_sync_log_device_id ON sync_log(device_id);
```

---

## 🔐 Row Level Security (RLS) Policies

Enable RLS on all tables for security:

### Enable RLS on All Tables
```sql
-- Users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Tasks
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Projects
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Tags
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

-- Categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Folders
ALTER TABLE folders ENABLE ROW LEVEL SECURITY;

-- Subtasks
ALTER TABLE subtasks ENABLE ROW LEVEL SECURITY;

-- Reminders
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Task Tags
ALTER TABLE task_tags ENABLE ROW LEVEL SECURITY;

-- Collaborators
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;

-- Attachments
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;

-- Sync Log
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;
```

### Create Policies for Each Table

#### Users Table Policies
```sql
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
```

#### Tasks Table Policies
```sql
-- Users can view their own tasks
CREATE POLICY "Users can view own tasks"
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
```

#### Projects Table Policies
```sql
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
```

#### Tags, Categories, Folders Policies
```sql
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
```

#### Subtasks, Reminders, Task Tags Policies
```sql
-- Subtasks (linked to tasks, inherit task permissions)
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

-- Reminders (linked to tasks)
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

-- Task Tags
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
```

#### Collaborators Policies
```sql
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
```

#### Attachments Policies
```sql
-- Users can manage attachments of own tasks/projects
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
```

#### Sync Log Policies
```sql
-- Users can manage their own sync logs
CREATE POLICY "Users can manage own sync logs"
ON sync_log FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

---

## 🔧 Enable Authentication Providers

1. Go to **Authentication > Providers** in Supabase dashboard
2. Enable these providers:
   - ✅ **Email/Password** (required)
   - ✅ **Google** (optional)
   - ✅ **Apple** (optional, for iOS)
   - ✅ **GitHub** (optional)
   - ✅ **Phone** (optional)

---

## 📁 Storage Setup (for File Attachments)

1. Go to **Storage > Create a bucket**
2. Create these buckets:
   - `attachments` - For task/project attachments
   - `avatars` - For user profile pictures
   - `thumbnails` - For image thumbnails

3. Set bucket policies:

```sql
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
```

---

## 📡 Real-time Subscriptions Setup

The app uses real-time subscriptions for live updates. Supabase handles this automatically once you:

1. Enable RLS policies (done above)
2. Use the Supabase client in your app

Example subscription in Flutter:

```dart
// Listen to real-time updates on tasks table
final subscription = Supabase.instance.client
    .from('tasks')
    .on(SupabaseEventTypes.all, (payload) {
  print('Change received: ${payload.eventType}');
  // Update local state
})
.subscribe();

// Don't forget to unsubscribe when done
subscription.unsubscribe();
```

---

## 🔄 Database Functions (Optional)

Create these helper functions for common operations:

### 1. Update Task Count in Projects
```sql
CREATE OR REPLACE FUNCTION update_project_task_counts()
RETURNS TRIGGER AS $$
BEGIN
  -- Update task count for project
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

-- Create trigger
DROP TRIGGER IF EXISTS trigger_update_project_counts ON tasks;
CREATE TRIGGER trigger_update_project_counts
AFTER INSERT OR UPDATE OR DELETE ON tasks
FOR EACH STATEMENT
EXECUTE FUNCTION update_project_task_counts();
```

### 2. Update Tag Usage Count
```sql
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
  -- Update usage count when task_tag is inserted
  IF TG_OP = 'INSERT' THEN
    UPDATE tags 
    SET usage_count = usage_count + 1, updated_at = NOW()
    WHERE id = NEW.tag_id;
  
  -- Update usage count when task_tag is deleted
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tags 
    SET usage_count = usage_count - 1, updated_at = NOW()
    WHERE id = OLD.tag_id;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_update_tag_usage ON task_tags;
CREATE TRIGGER trigger_update_tag_usage
AFTER INSERT OR DELETE ON task_tags
FOR EACH ROW
EXECUTE FUNCTION update_tag_usage_count();
```

---

## 🧪 Testing Your Setup

### 1. Test Authentication
```dart
// Sign up
final authResponse = await Supabase.instance.client.auth.signUp(
  email: 'test@example.com',
  password: 'password123',
);

// Sign in
final authResponse = await Supabase.instance.client.auth.signInWithPassword(
  email: 'test@example.com',
  password: 'password123',
);

// Get current user
final user = Supabase.instance.client.auth.currentUser;
```

### 2. Test Database Operations
```dart
// Insert a task
final task = await Supabase.instance.client.from('tasks').insert({
  'title': 'Test Task',
  'description': 'This is a test',
  'priority': 2,
  'user_id': user.id,
}).select();

// Fetch tasks
final tasks = await Supabase.instance.client
    .from('tasks')
    .select()
    .eq('user_id', user.id)
    .order('created_at', ascending: false);

// Update task
final updated = await Supabase.instance.client.from('tasks')
    .update({'is_completed': true})
    .eq('id', task.id)
    .select();

// Delete task
await Supabase.instance.client.from('tasks')
    .delete()
    .eq('id', task.id);
```

### 3. Test Real-time
```dart
final subscription = Supabase.instance.client
    .from('tasks')
    .on(SupabaseEventTypes.all, (payload) {
  debugPrint('Task changed: ${payload.eventType}');
})
.subscribe();
```

---

## 🚀 Deployment Checklist

- [ ] Create Supabase project
- [ ] Get project URL and anon key
- [ ] Update `pubspec.yaml` with supabase_flutter
- [ ] Update `main.dart` with Supabase initialization
- [ ] Create all database tables
- [ ] Enable RLS on all tables
- [ ] Create RLS policies for all tables
- [ ] Enable authentication providers
- [ ] Create storage buckets
- [ ] Set storage policies
- [ ] Test authentication
- [ ] Test database operations
- [ ] Test real-time subscriptions

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Supabase SQL](https://supabase.com/docs/guides/database)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Supabase Storage](https://supabase.com/docs/guides/storage)

---

## 🆘 Troubleshooting

### Common Issues

**1. Connection Failed**
- Check your Supabase URL and anon key
- Ensure you've called `Supabase.initialize()` before using the client
- Verify your internet connection

**2. RLS Policies Not Working**
- Make sure RLS is enabled on the table
- Check your policies for syntax errors
- Use the Supabase dashboard to test policies

**3. Authentication Not Working**
- Enable the email/password provider
- Check for typos in your code
- Test with the Supabase JavaScript client first

**4. Real-time Not Working**
- Ensure RLS policies allow SELECT
- Check your subscription code
- Verify you're subscribed to the correct table

**5. Storage Upload Failed**
- Check bucket policies
- Ensure the bucket exists
- Verify file metadata includes task_id or project_id

---

## 🎯 Next Steps

1. **Test locally** with mock data first
2. **Set up Supabase** using this guide
3. **Gradually migrate** from mock to real data
4. **Add more features** as needed

---

<p align="center">
  Happy coding with Supabase! 🚀
</p>

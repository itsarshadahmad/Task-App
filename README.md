# Task App - Comprehensive Task Management System

A modern, feature-rich task management application built with Flutter, designed for productivity, collaboration, and seamless cross-platform experience.

## 🚀 Quick Start

The app now supports **3 backend modes** - choose what works best for you!

### Option 1: Mock Mode (Easiest - No Setup Required)
```bash
# Clone the repository
git clone https://github.com/itsarshadahmad/Task-App.git
cd Task-App

# Get dependencies
flutter pub get

# Run the app
flutter run
```
✅ Works immediately with pre-loaded sample data
✅ All UI/UX features working
✅ Perfect for testing without any configuration

### Option 2: Firebase Mode
For real-time cloud sync with Firebase:

1. Uncomment Firebase packages in `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
```

2. Configure Firebase in `main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

3. Set up Firebase project and update `firebase_options.dart`

### Option 3: Supabase Mode
For open-source cloud sync with Supabase:

1. Add Supabase package to `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

2. Configure Supabase in `main.dart`:
```dart
await SupabaseService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

3. Create a Supabase project at https://supabase.com/

---

## Features

### Core Functionality
- **Task Management**: Create, edit, delete, and organize tasks with rich details
- **Projects**: Group tasks into projects with custom colors and icons
- **Tags & Categories**: Organize tasks with flexible tagging and categorization
- **Folders**: Create nested folder structures for better organization
- **Subtasks**: Break down complex tasks into manageable subtasks
- **Reminders**: Set up one-time or recurring reminders for important tasks

### Views
- **List View**: Traditional task list with filtering and sorting
- **Board View**: Kanban-style board for visual task management
- **Calendar View**: View tasks by date with full calendar integration

### Advanced Features
- **Real-time Collaboration**: Work with team members in real-time (Firebase/Supabase)
- **Cloud Synchronization**: Sync data across all devices
- **Offline Support**: Full offline functionality with automatic sync when online
- **End-to-End Encryption**: Secure your data with AES-256 encryption
- **Voice-to-Text**: Create tasks using voice commands
- **Haptic Feedback**: Tactile feedback for all interactions
- **AI-Powered Reminders**: Smart reminder suggestions based on task patterns
- **Progress Reporting**: Automated project progress tracking and analytics

### UI/UX
- **Material You Design**: Dynamic color theming that adapts to your system
- **Dark Mode**: Full dark mode support with Material 3
- **Fluid Animations**: Smooth, appealing transitions between views
- **Responsive Design**: Works seamlessly on mobile, tablet, and desktop
- **Customizable**: Personalize colors, themes, and layouts

### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Main app widget
├── firebase_options.dart        # Firebase configuration (optional)
│
├── core/                        # Core functionality
│   ├── models/                  # Data models (10 files)
│   │   ├── task_model.dart
│   │   ├── project_model.dart
│   │   ├── subtask_model.dart
│   │   ├── reminder_model.dart
│   │   ├── tag_model.dart
│   │   ├── category_model.dart
│   │   ├── folder_model.dart
│   │   └── user_model.dart
│   │
│   ├── constants/               # App constants
│   │   └── app_constants.dart
│   │
│   ├── repositories/            # Data repositories (6 files)
│   │   ├── base_repository.dart
│   │   ├── task_repository.dart
│   │   ├── project_repository.dart
│   │   ├── tag_repository.dart
│   │   ├── category_repository.dart
│   │   └── folder_repository.dart
│   │
│   ├── services/                # Core services (9 files)
│   │   ├── database_service.dart        # Abstract database layer
│   │   ├── mock_database_service.dart   # Offline mock database
│   │   ├── supabase_service.dart        # Supabase integration
│   │   ├── sync_service.dart
│   │   ├── encryption_service.dart
│   │   ├── voice_service.dart
│   │   ├── notification_service.dart
│   │   ├── haptic_service.dart
│   │   └── analytics_service.dart
│   │
│   └── theme/                   # App theming
│       └── app_theme.dart
│
├── features/                    # Feature modules
│   ├── tasks/                   # Task management
│   │   ├── providers/
│   │   │   └── task_provider.dart
│   │   └── screens/
│   │       └── task_list_screen.dart
│   │
│   ├── projects/                # Project management
│   │   ├── providers/
│   │   │   └── project_provider.dart
│   │   ├── screens/
│   │   │   └── project_list_screen.dart
│   │   └── widgets/
│   │       └── project_card.dart
│   │
│   ├── calendar/                # Calendar view
│   │   └── screens/
│   │       └── calendar_screen.dart
│   │
│   ├── board/                   # Board view (Kanban)
│   │   └── screens/
│   │       └── board_screen.dart
│   │
│   ├── auth/                    # Authentication
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       └── login_screen.dart
│   │
│   └── settings/                # App settings
│       ├── providers/
│       │   └── settings_provider.dart
│       └── screens/
│           └── settings_screen.dart
│
└── shared/                     # Shared components
    ├── widgets/                # Reusable widgets (16 files)
    │   ├── app_text_field.dart
    │   ├── app_button.dart
    │   ├── task_card.dart
    │   ├── project_card.dart
    │   ├── main_scaffold.dart
    │   ├── search_bar.dart
    │   ├── filter_chips.dart
    │   ├── voice_input_button.dart
    │   ├── progress_indicator.dart
    │   ├── avatar_widget.dart
    │   ├── confirmation_dialog.dart
    │   ├── color_picker_dialog.dart
    │   └── empty_state.dart
    │
    ├── utils/                  # Utility functions
    │   └── app_helpers.dart
    │
    └── animations/            # Custom animations
        └── transitions.dart
```

---

## 🎯 Getting Started with Firebase

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/)
- Click "Add project" and follow the steps

### 2. Add Apps to Firebase
- Add Android, iOS, and Web apps to your project
- Download configuration files

### 3. Enable Services
- Firebase Authentication
- Cloud Firestore (Database)
- Firebase Storage

### 4. Update Configuration
- Update `lib/firebase_options.dart` with your Firebase config
- Or use FlutterFire CLI:
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure
  ```

---

## 🎯 Getting Started with Supabase

### 1. Create Supabase Project
- Go to [Supabase](https://supabase.com/)
- Create a new project

### 2. Get Credentials
- Find your Supabase URL and anon key in Project Settings > API

### 3. Update Configuration
In `main.dart`:
```dart
await SupabaseService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

---

## 🔧 Configuration

### Environment Variables (Optional)
Create a `.env` file for development:
```env
# Firebase
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id

# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

### Database Collections/Tables
The app uses the following data structures:
- `users` - User accounts and profiles
- `tasks` - Individual tasks
- `projects` - Task groups/projects
- `tags` - Task tags
- `categories` - Task categories
- `folders` - Folder structures
- `reminders` - Task reminders
- `subtasks` - Task subtasks

---

## 🛠️ Architecture

### State Management
- **Riverpod** for reactive state management
- **Provider** pattern for dependency injection
- **StateNotifier** for complex state logic

### Data Layer
- **Repository Pattern** for data access
- **Offline-First** with Hive for local storage
- **Automatic Sync** with Firebase/Supabase

### Services
- **Authentication**: Firebase Auth / Supabase Auth
- **Database**: Firestore / Supabase Realtime
- **Storage**: Firebase Storage / Supabase Storage
- **Notifications**: Local notifications for reminders
- **Voice**: Speech-to-text for task creation
- **Analytics**: Track productivity patterns
- **Encryption**: AES-256 for data security
- **Haptics**: Device vibration feedback

---

## 📱 Running the App

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

### Desktop
```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

---

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Run specific test files:
```bash
flutter test test/widget_tests/
flutter test test/unit_tests/
```

---

## 📦 Building for Release

### Android
```bash
flutter build apk
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

### Desktop
```bash
flutter build windows
flutter build macos
flutter build linux
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - The amazing cross-platform framework
- [Firebase](https://firebase.google.com/) - Powerful backend services
- [Supabase](https://supabase.com/) - Open-source Firebase alternative
- [Riverpod](https://riverpod.dev/) - State management solution
- All contributors and open-source projects used in this app

---

## 🆘 Support

For issues, questions, or feature requests:

1. **GitHub Issues**: Open an issue on [GitHub](https://github.com/itsarshadahmad/Task-App/issues)
2. **Discussions**: Join the discussion at [GitHub Discussions](https://github.com/itsarshadahmad/Task-App/discussions)
3. **Email**: Contact the maintainer

---

## 📞 Contact

- **GitHub**: [itsarshadahmad](https://github.com/itsarshadahmad)
- **Repository**: [Task-App](https://github.com/itsarshadahmad/Task-App)

---

## 🎯 Roadmap

### Upcoming Features
- [ ] Multi-language support (i18n)
- [ ] Advanced analytics dashboard
- [ ] Team collaboration features
- [ ] Calendar sync with Google Calendar
- [ ] Task templates
- [ ] Recurring task patterns
- [ ] Export/Import data
- [ ] Backup and restore

### Planned Improvements
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] More customization options
- [ ] Integration with more services

---

<p align="center">
  Made with ❤️ using Flutter
</p>

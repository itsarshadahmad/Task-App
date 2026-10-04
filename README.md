# Task App - Comprehensive Task Management System

A modern, feature-rich task management application built with Flutter, designed for productivity, collaboration, and seamless cross-platform experience.

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
- **Real-time Collaboration**: Work with team members in real-time
- **Cloud Synchronization**: Sync data across all devices with Firebase
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
- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Architecture

### State Management
- Riverpod for reactive state management
- Provider pattern for dependency injection

### Data Layer
- **Firebase**: Cloud Firestore for real-time data
- **Hive**: Local storage for offline-first architecture
- **Sync Service**: Automatic synchronization between local and cloud

### Services
- **Authentication**: Firebase Auth with email, Google, Apple, Facebook
- **Notifications**: Local notifications for reminders
- **Voice Recognition**: Speech-to-text for task creation
- **Analytics**: Track productivity and usage patterns
- **Encryption**: AES-256 encryption for sensitive data
- **Haptic Feedback**: Device vibration for user feedback

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-repo/task-app.git
cd task-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
   - Create a Firebase project
   - Add your Firebase configuration to `lib/firebase_options.dart`
   - Enable Firestore, Authentication, and Storage

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── app.dart                    # Main app widget
├── main.dart                   # Entry point
├── firebase_options.dart      # Firebase configuration
│
├── core/                       # Core functionality
│   ├── models/                 # Data models
│   │   ├── task_model.dart
│   │   ├── project_model.dart
│   │   ├── subtask_model.dart
│   │   ├── reminder_model.dart
│   │   ├── tag_model.dart
│   │   ├── category_model.dart
│   │   ├── folder_model.dart
│   │   └── user_model.dart
│   │
│   ├── constants/              # App constants
│   │   └── app_constants.dart
│   │
│   ├── repositories/           # Data repositories
│   │   ├── base_repository.dart
│   │   ├── task_repository.dart
│   │   ├── project_repository.dart
│   │   ├── tag_repository.dart
│   │   ├── category_repository.dart
│   │   └── folder_repository.dart
│   │
│   ├── services/               # Core services
│   │   ├── sync_service.dart
│   │   ├── encryption_service.dart
│   │   ├── voice_service.dart
│   │   ├── notification_service.dart
│   │   ├── haptic_service.dart
│   │   ├── analytics_service.dart
│   │   └── ai_service.dart
│   │
│   └── theme/                  # App theming
│       └── app_theme.dart
│
├── features/                   # Feature modules
│   ├── tasks/                  # Task management
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── projects/               # Project management
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── calendar/               # Calendar view
│   │   ├── screens/
│   │   ├── providers/
│   │   └── widgets/
│   │
│   ├── board/                  # Board view
│   │   ├── screens/
│   │   ├── providers/
│   │   └── widgets/
│   │
│   ├── auth/                   # Authentication
│   │   ├── screens/
│   │   ├── providers/
│   │   └── services/
│   │
│   └── settings/               # App settings
│       ├── screens/
│       ├── providers/
│       └── widgets/
│
└── shared/                    # Shared components
    ├── widgets/               # Reusable widgets
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
    ├── utils/                 # Utility functions
    │   └── app_helpers.dart
    │
    └── animations/            # Custom animations
        └── transitions.dart
```

## Configuration

### Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android, iOS, and Web apps to your project
3. Download the configuration files and update `firebase_options.dart`
4. Enable the following services:
   - Firebase Authentication
   - Cloud Firestore
   - Firebase Storage
   - Firebase Cloud Messaging (optional for push notifications)

### Hive Setup
The app uses Hive for local storage. Adapters are automatically generated for models with freezed.

### Environment Variables
Create a `.env` file for development:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id
```

## Usage

### Creating a Task
```dart
final task = Task.create(
  title: 'Complete project',
  description: 'Finish the Flutter project by Friday',
  projectId: 'project_123',
  priority: 3, // High priority
  dueDate: DateTime.now().add(Duration(days: 2)),
);

// Add to repository
final taskRepo = ref.read(taskRepositoryProvider(userId));
await taskRepo.create(task);
```

### Querying Tasks
```dart
// Get all tasks
final tasks = await taskRepo.getAll();

// Get tasks by project
final projectTasks = await taskRepo.getTasksByProject(projectId);

// Get today's tasks
final todayTasks = await taskRepo.getTodayTasks();
```

### Real-time Updates
The app automatically syncs data between local storage and Firebase. Changes made offline will sync when connection is restored.

## Customization

### Theming
The app supports Material You dynamic colors. Customize the theme in `lib/core/theme/app_theme.dart`.

### Colors
Projects, tags, and folders can be customized with any color. Use the `ColorPickerDialog` widget for color selection.

## Testing

Run tests with:
```bash
flutter test
```

## Deployment

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the powerful backend services
- All contributors and open-source projects used in this app

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

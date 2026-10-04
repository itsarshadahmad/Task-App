class AppConstants {
  static const String appName = 'Task App';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String storageUserKey = 'user';
  static const String storageThemeKey = 'theme';
  static const String storageLanguageKey = 'language';
  static const String storageOnboardingKey = 'onboarding';
  static const String storageBiometricsKey = 'biometrics';
  
  // Database collection names
  static const String collectionUsers = 'users';
  static const String collectionTasks = 'tasks';
  static const String collectionProjects = 'projects';
  static const String collectionTags = 'tags';
  static const String collectionCategories = 'categories';
  static const String collectionFolders = 'folders';
  static const String collectionReminders = 'reminders';
  static const String collectionSubtasks = 'subtasks';
  static const String collectionSyncLog = 'sync_log';
  
  // Hive box names
  static const String hiveTasksBox = 'tasks';
  static const String hiveProjectsBox = 'projects';
  static const String hiveTagsBox = 'tags';
  static const String hiveCategoriesBox = 'categories';
  static const String hiveFoldersBox = 'folders';
  static const String hiveRemindersBox = 'reminders';
  static const String hiveSettingsBox = 'settings';
  static const String hiveSyncBox = 'sync';
  
  // Priority levels
  static const int priorityNone = 0;
  static const int priorityLow = 1;
  static const int priorityMedium = 2;
  static const int priorityHigh = 3;
  static const int priorityUrgent = 4;
  
  // Reminder types
  static const String reminderTypeOnce = 'once';
  static const String reminderTypeDaily = 'daily';
  static const String reminderTypeWeekly = 'weekly';
  static const String reminderTypeMonthly = 'monthly';
  static const String reminderTypeYearly = 'yearly';
  static const String reminderTypeCustom = 'custom';
  
  // Recurrence patterns
  static const String recurrenceDaily = 'daily';
  static const String recurrenceWeekly = 'weekly';
  static const String recurrenceMonthly = 'monthly';
  static const String recurrenceYearly = 'yearly';
  static const String recurrenceCustom = 'custom';
  
  // Task filters
  static const String filterAll = 'all';
  static const String filterToday = 'today';
  static const String filterUpcoming = 'upcoming';
  static const String filterOverdue = 'overdue';
  static const String filterCompleted = 'completed';
  static const String filterIncomplete = 'incomplete';
  static const String filterPinned = 'pinned';
  static const String filterArchived = 'archived';
  
  // View types
  static const String viewList = 'list';
  static const String viewBoard = 'board';
  static const String viewCalendar = 'calendar';
  
  // Sort options
  static const String sortByDate = 'date';
  static const String sortByPriority = 'priority';
  static const String sortByTitle = 'title';
  static const String sortByManual = 'manual';
  
  // User roles
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleUser = 'user';
  static const String roleGuest = 'guest';
  
  // Date formats
  static const String dateFormatShort = 'MMM d';
  static const String dateFormatMedium = 'MMM d, yyyy';
  static const String dateFormatLong = 'MMMM d, yyyy';
  static const String dateFormatFull = 'EEEE, MMMM d, yyyy';
  static const String timeFormat = 'h:mm a';
  static const String dateTimeFormat = 'MMM d, yyyy h:mm a';
  
  // Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration animationDurationVerySlow = Duration(milliseconds: 1000);
  
  // Sync intervals
  static const Duration syncInterval = Duration(minutes: 1);
  static const Duration offlineRetryInterval = Duration(seconds: 30);
  static const int maxSyncRetries = 3;
  
  // Pagination
  static const int itemsPerPage = 20;
  static const int maxItemsPerPage = 100;
  
  // Validation
  static const int maxTitleLength = 120;
  static const int maxDescriptionLength = 10000;
  static const int maxTagNameLength = 30;
  static const int maxProjectNameLength = 60;
  static const int maxCategoryNameLength = 50;
  static const int maxFolderNameLength = 50;
  
  // Default colors
  static const List<String> defaultColors = [
    '#FF6750A4', // Purple
    '#FF625B71', // Grey
    '#FF7D5260', // Pink
    '#FFB388FF', // Light Purple
    '#FF0288D1', // Blue
    '#FF009688', // Teal
    '#FF4CAF50', // Green
    '#FFFFC107', // Amber
    '#FFFF9800', // Orange
    '#FFF44336', // Red
    '#FFE91E63', // Pink
    '#FF9C27B0', // Purple
    '#FF3F51B5', // Indigo
  ];
  
  // Default icons
  static const List<String> defaultIcons = [
    'work',
    'personal',
    'shopping',
    'health',
    'finance',
    'education',
    'travel',
    'entertainment',
    'food',
    'sports',
    'music',
    'art',
    'technology',
    'home',
    'family',
  ];
}

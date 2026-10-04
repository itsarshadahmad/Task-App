import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/task_model.dart';
import '../../../core/repositories/task_repository.dart';
import '../../../core/constants/app_constants.dart';

final taskListProvider = StateNotifierProvider.family<TaskListNotifier, AsyncValue<List<Task>>, String>((ref, userId) {
  return TaskListNotifier(
    userId: userId,
    ref: ref,
  );
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final String userId;
  final ProviderRef ref;
  
  String _currentFilter = AppConstants.filterAll;
  String _searchQuery = '';
  String? _projectId;
  String? _tagId;
  String? _categoryId;
  DateTime? _selectedDate;

  TaskListNotifier({
    required this.userId,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(taskRepositoryProvider(userId));
      var tasks = await repository.getAll();
      
      // Apply filters
      tasks = _applyFilters(tasks);
      
      state = AsyncValue.data(tasks);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  List<Task> _applyFilters(List<Task> tasks) {
    var filtered = tasks;
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) =>
        task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Filter by type
    switch (_currentFilter) {
      case AppConstants.filterToday:
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day + 1);
        filtered = filtered.where((task) =>
          task.dueDate != null &&
          task.dueDate!.isAfter(startOfDay) &&
          task.dueDate!.isBefore(endOfDay)
        ).toList();
        break;
      case AppConstants.filterUpcoming:
        filtered = filtered.where((task) =>
          task.dueDate != null &&
          task.dueDate!.isAfter(DateTime.now())
        ).toList();
        break;
      case AppConstants.filterOverdue:
        filtered = filtered.where((task) =>
          task.dueDate != null &&
          task.dueDate!.isBefore(DateTime.now()) &&
          !task.isCompleted
        ).toList();
        break;
      case AppConstants.filterCompleted:
        filtered = filtered.where((task) => task.isCompleted).toList();
        break;
      case AppConstants.filterIncomplete:
        filtered = filtered.where((task) => !task.isCompleted).toList();
        break;
      case AppConstants.filterPinned:
        filtered = filtered.where((task) => task.isPinned).toList();
        break;
      case AppConstants.filterArchived:
        filtered = filtered.where((task) => task.isArchived).toList();
        break;
    }
    
    // Project filter
    if (_projectId != null) {
      filtered = filtered.where((task) => task.projectId == _projectId).toList();
    }
    
    // Tag filter
    if (_tagId != null) {
      filtered = filtered.where((task) => task.tagIds.contains(_tagId)).toList();
    }
    
    // Category filter
    if (_categoryId != null) {
      filtered = filtered.where((task) => task.categoryId == _categoryId).toList();
    }
    
    // Date filter
    if (_selectedDate != null) {
      final startOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      final endOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day + 1,
      );
      filtered = filtered.where((task) =>
        task.dueDate != null &&
        task.dueDate!.isAfter(startOfDay) &&
        task.dueDate!.isBefore(endOfDay)
      ).toList();
    }
    
    // Sort by priority (highest first), then by due date
    filtered.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return b.createdAt!.compareTo(a.createdAt!);
    });
    
    return filtered;
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    loadTasks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTasks();
  }

  void setProjectFilter(String? projectId) {
    _projectId = projectId;
    loadTasks();
  }

  void setTagFilter(String? tagId) {
    _tagId = tagId;
    loadTasks();
  }

  void setCategoryFilter(String? categoryId) {
    _categoryId = categoryId;
    loadTasks();
  }

  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    loadTasks();
  }

  Future<void> refresh() async => await loadTasks();

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final repository = ref.read(taskRepositoryProvider(userId));
    await repository.toggleTaskCompletion(taskId, isCompleted);
    await loadTasks();
  }

  Future<void> addTask(Task task) async {
    final repository = ref.read(taskRepositoryProvider(userId));
    await repository.create(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final repository = ref.read(taskRepositoryProvider(userId));
    await repository.update(task);
    await loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    final repository = ref.read(taskRepositoryProvider(userId));
    await repository.delete(taskId);
    await loadTasks();
  }

  String get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
}

final selectedTasksProvider = StateProvider<List<String>>((ref) => []);

final taskDetailProvider = StateNotifierProvider.family<TaskDetailNotifier, AsyncValue<Task?>, String>((ref, taskId) {
  return TaskDetailNotifier(
    taskId: taskId,
    ref: ref,
  );
});

class TaskDetailNotifier extends StateNotifier<AsyncValue<Task?>> {
  final String taskId;
  final ProviderRef ref;

  TaskDetailNotifier({
    required this.taskId,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadTask();
  }

  Future<void> loadTask() async {
    state = const AsyncValue.loading();
    
    try {
      // Get userId from auth
      final userId = 'current_user_id'; // Will be replaced with actual userId
      final repository = ref.read(taskRepositoryProvider(userId));
      final task = await repository.getById(taskId);
      state = AsyncValue.data(task);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

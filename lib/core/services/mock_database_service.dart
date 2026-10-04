// Mock Database Service - For offline-only testing without Firebase/Supabase
// This allows the app to run without any backend configuration

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'database_service.dart';

class MockDatabaseService implements DatabaseService {
  final _data = <String, List<Map<String, dynamic>>>{};
  final _subscriptions = <String, StreamController<List<Map<String, dynamic>>>>{};
  String? _currentUserId;
  final _authController = StreamController<bool>.broadcast();
  
  MockDatabaseService() {
    _currentUserId = const Uuid().v4();
    _authController.add(true);
  }

  @override
  Future<void> initialize() async {
    // Initialize with some mock data
    await _seedMockData();
  }

  Future<void> _seedMockData() async {
    // Create mock user
    _currentUserId = const Uuid().v4();
    
    // Mock projects
    _data['projects'] = [
      {
        'id': const Uuid().v4(),
        'name': 'Personal Tasks',
        'color': '#FF6750A4',
        'description': 'My personal tasks',
        'userId': _currentUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isPinned': true,
        'order': 0,
      },
      {
        'id': const Uuid().v4(),
        'name': 'Work Projects',
        'color': '#FF0288D1',
        'description': 'Work-related tasks',
        'userId': _currentUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isPinned': false,
        'order': 1,
      },
    ];
    
    // Mock tags
    _data['tags'] = [
      {
        'id': const Uuid().v4(),
        'name': 'Important',
        'color': '#FFF44336',
        'userId': _currentUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'usageCount': 0,
      },
      {
        'id': const Uuid().v4(),
        'name': 'Work',
        'color': '#FF0288D1',
        'userId': _currentUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'usageCount': 0,
      },
      {
        'id': const Uuid().v4(),
        'name': 'Personal',
        'color': '#FF4CAF50',
        'userId': _currentUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'usageCount': 0,
      },
    ];
    
    // Mock tasks
    final projectId = _data['projects']!.first['id'];
    _data['tasks'] = [
      {
        'id': const Uuid().v4(),
        'title': 'Complete project proposal',
        'description': 'Finish the proposal document for the client',
        'isCompleted': false,
        'priority': 3,
        'dueDate': DateTime.now().add(Duration(days: 2)).toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'projectId': projectId,
        'userId': _currentUserId,
        'tagIds': [_data['tags']!.first['id']],
        'subtasks': [],
        'reminders': [],
        'isPinned': true,
        'color': null,
      },
      {
        'id': const Uuid().v4(),
        'title': 'Buy groceries',
        'description': 'Milk, eggs, bread, vegetables',
        'isCompleted': false,
        'priority': 1,
        'dueDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'projectId': projectId,
        'userId': _currentUserId,
        'tagIds': [_data['tags']![2]['id']],
        'subtasks': [],
        'reminders': [],
        'isPinned': false,
        'color': null,
      },
      {
        'id': const Uuid().v4(),
        'title': 'Call mom',
        'description': 'Weekly check-in call',
        'isCompleted': false,
        'priority': 2,
        'dueDate': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'projectId': null,
        'userId': _currentUserId,
        'tagIds': [],
        'subtasks': [],
        'reminders': [],
        'isPinned': false,
        'color': null,
      },
    ];
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    // In mock mode, just set a user ID
    _currentUserId = const Uuid().v4();
    _authController.add(true);
    await _seedMockData();
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    _currentUserId = const Uuid().v4();
    _authController.add(true);
    await _seedMockData();
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
    _authController.add(false);
  }

  @override
  String? get currentUserId => _currentUserId;

  @override
  Stream<bool> get authStateStream => _authController.stream.map((isLoggedIn) => isLoggedIn);

  @override
  Future<List<Map<String, dynamic>>> fetchData(String table, {Map<String, dynamic>? filters}) async {
    if (!_data.containsKey(table)) {
      _data[table] = [];
    }
    
    var data = _data[table]!;
    
    // Apply filters
    if (filters != null) {
      data = data.where((item) {
        bool matches = true;
        filters.forEach((key, value) {
          if (item[key] != value) {
            matches = false;
          }
        });
        return matches;
      }).toList();
    }
    
    // Filter by user if not already filtered
    if (_currentUserId != null && !filters?.containsKey('userId') ?? true) {
      data = data.where((item) => item['userId'] == _currentUserId).toList();
    }
    
    return data;
  }

  @override
  Future<Map<String, dynamic>> insertData(String table, Map<String, dynamic> data) async {
    if (!_data.containsKey(table)) {
      _data[table] = [];
    }
    
    final newData = Map<String, dynamic>.from(data);
    if (!newData.containsKey('id')) {
      newData['id'] = const Uuid().v4();
    }
    if (!newData.containsKey('userId') && _currentUserId != null) {
      newData['userId'] = _currentUserId;
    }
    if (!newData.containsKey('createdAt')) {
      newData['createdAt'] = DateTime.now().toIso8601String();
    }
    if (!newData.containsKey('updatedAt')) {
      newData['updatedAt'] = DateTime.now().toIso8601String();
    }
    
    _data[table]!.add(newData);
    
    // Notify subscribers
    if (_subscriptions.containsKey(table)) {
      _subscriptions[table]!.add(_data[table]!);
    }
    
    return newData;
  }

  @override
  Future<Map<String, dynamic>> updateData(String table, Map<String, dynamic> data, String id) async {
    if (!_data.containsKey(table)) {
      throw Exception('Table $table not found');
    }
    
    final index = _data[table]!.indexWhere((item) => item['id'] == id);
    if (index == -1) {
      throw Exception('Item with id $id not found in $table');
    }
    
    final updatedData = Map<String, dynamic>.from(_data[table]![index]);
    updatedData.addAll(data);
    updatedData['updatedAt'] = DateTime.now().toIso8601String();
    
    _data[table]![index] = updatedData;
    
    // Notify subscribers
    if (_subscriptions.containsKey(table)) {
      _subscriptions[table]!.add(_data[table]!);
    }
    
    return updatedData;
  }

  @override
  Future<void> deleteData(String table, String id) async {
    if (!_data.containsKey(table)) {
      throw Exception('Table $table not found');
    }
    
    _data[table]!.removeWhere((item) => item['id'] == id);
    
    // Notify subscribers
    if (_subscriptions.containsKey(table)) {
      _subscriptions[table]!.add(_data[table]!);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> subscribeToTable(String table, {Map<String, dynamic>? filters}) {
    if (!_subscriptions.containsKey(table)) {
      _subscriptions[table] = StreamController<List<Map<String, dynamic>>>();
    }
    
    // Initial data
    final initialData = _data[table] ?? [];
    
    // Apply filters
    var filteredData = initialData;
    if (filters != null) {
      filteredData = filteredData.where((item) {
        bool matches = true;
        filters.forEach((key, value) {
          if (item[key] != value) {
            matches = false;
          }
        });
        return matches;
      }).toList();
    }
    
    // Filter by user
    if (_currentUserId != null) {
      filteredData = filteredData.where((item) => item['userId'] == _currentUserId).toList();
    }
    
    // Create a new stream that combines initial data with updates
    final controller = StreamController<List<Map<String, dynamic>>>();
    
    // Send initial data
    controller.add(filteredData);
    
    // Listen to updates
    final subscription = _subscriptions[table]!.stream.listen((data) {
      var filtered = data;
      if (filters != null) {
        filtered = filtered.where((item) {
          bool matches = true;
          filters.forEach((key, value) {
            if (item[key] != value) {
              matches = false;
            }
          });
          return matches;
        }).toList();
      }
      if (_currentUserId != null) {
        filtered = filtered.where((item) => item['userId'] == _currentUserId).toList();
      }
      controller.add(filtered);
    });
    
    // Cleanup on close
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    
    return controller.stream;
  }

  @override
  Future<List<Map<String, dynamic>>> batchInsert(String table, List<Map<String, dynamic>> data) async {
    if (!_data.containsKey(table)) {
      _data[table] = [];
    }
    
    final now = DateTime.now().toIso8601String();
    final results = <Map<String, dynamic>>[];
    
    for (final item in data) {
      final newData = Map<String, dynamic>.from(item);
      if (!newData.containsKey('id')) {
        newData['id'] = const Uuid().v4();
      }
      if (!newData.containsKey('userId') && _currentUserId != null) {
        newData['userId'] = _currentUserId;
      }
      if (!newData.containsKey('createdAt')) {
        newData['createdAt'] = now;
      }
      if (!newData.containsKey('updatedAt')) {
        newData['updatedAt'] = now;
      }
      
      _data[table]!.add(newData);
      results.add(newData);
    }
    
    // Notify subscribers
    if (_subscriptions.containsKey(table)) {
      _subscriptions[table]!.add(_data[table]!);
    }
    
    return results;
  }

  @override
  Future<void> batchUpdate(String table, List<Map<String, dynamic>> updates) async {
    if (!_data.containsKey(table)) {
      throw Exception('Table $table not found');
    }
    
    final now = DateTime.now().toIso8601String();
    
    for (final update in updates) {
      final id = update['id'];
      final index = _data[table]!.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        final updatedData = Map<String, dynamic>.from(_data[table]![index]);
        updatedData.addAll(update);
        updatedData.remove('id');
        updatedData['updatedAt'] = now;
        _data[table]![index] = updatedData;
      }
    }
    
    // Notify subscribers
    if (_subscriptions.containsKey(table)) {
      _subscriptions[table]!.add(_data[table]!);
    }
  }

  @override
  Future<void> batchDelete(String table, List<String> ids) async {
    if (!_data.containsKey(table)) {
      throw Exception('Table $table not found');
    }
    
    _data[table]!.removeWhere((item) => ids.contains(item['id']));
    
    // Notify subscribers
    if (_subscriptions.containsKey(table)) {
      _subscriptions[table]!.add(_data[table]!);
    }
  }

  @override
  void dispose() {
    _authController.close();
    for (final controller in _subscriptions.values) {
      controller.close();
    }
  }
}

final mockDatabaseServiceProvider = Provider<MockDatabaseService>((ref) {
  final service = MockDatabaseService();
  ref.onDispose(() => service.dispose());
  return service;
});

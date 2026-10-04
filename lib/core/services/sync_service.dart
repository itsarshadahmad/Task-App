import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../repositories/task_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/tag_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/folder_repository.dart';
import '../constants/app_constants.dart';
import 'encryption_service.dart';

class SyncService {
  final String userId;
  final ProviderRef ref;
  final EncryptionService encryptionService;

  SyncService({
    required this.userId,
    required this.ref,
    required this.encryptionService,
  });

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  Future<void> syncAll() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      
      if (result == ConnectivityResult.none) {
        _isSyncing = false;
        return;
      }

      // Sync all repositories
      final taskRepo = ref.read(taskRepositoryProvider(userId));
      final projectRepo = ref.read(projectRepositoryProvider(userId));
      final tagRepo = ref.read(tagRepositoryProvider(userId));
      final categoryRepo = ref.read(categoryRepositoryProvider(userId));
      final folderRepo = ref.read(folderRepositoryProvider(userId));

      await Future.wait([
        taskRepo.syncToCloud(),
        projectRepo.syncToCloud(),
        tagRepo.syncToCloud(),
        categoryRepo.syncToCloud(),
        folderRepo.syncToCloud(),
      ]);

      _lastSyncTime = DateTime.now();
      
    } catch (e) {
      // Sync failed
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> startAutoSync() async {
    while (true) {
      await syncAll();
      await Future.delayed(AppConstants.syncInterval);
    }
  }

  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;
}

final syncServiceProvider = Provider.family<SyncService, String>((ref, userId) {
  return SyncService(
    userId: userId,
    ref: ref,
    encryptionService: ref.read(encryptionServiceProvider),
  );
});

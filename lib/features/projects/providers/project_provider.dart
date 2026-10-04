import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/project_model.dart';
import '../../../core/repositories/project_repository.dart';

final projectListProvider = StateNotifierProvider.family<ProjectListNotifier, AsyncValue<List<Project>>, String>((ref, userId) {
  return ProjectListNotifier(
    userId: userId,
    ref: ref,
  );
});

class ProjectListNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final String userId;
  final ProviderRef ref;
  
  bool _showArchived = false;

  ProjectListNotifier({
    required this.userId,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(projectRepositoryProvider(userId));
      var projects = await repository.getAll();
      
      if (!_showArchived) {
        projects = projects.where((p) => !p.isArchived).toList();
      }
      
      // Sort: pinned first, then by order
      projects.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return a.order.compareTo(b.order);
      });
      
      state = AsyncValue.data(projects);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setShowArchived(bool show) {
    _showArchived = show;
    loadProjects();
  }

  Future<void> refresh() async => await loadProjects();

  Future<void> addProject(Project project) async {
    final repository = ref.read(projectRepositoryProvider(userId));
    await repository.create(project);
    await loadProjects();
  }

  Future<void> updateProject(Project project) async {
    final repository = ref.read(projectRepositoryProvider(userId));
    await repository.update(project);
    await loadProjects();
  }

  Future<void> deleteProject(String projectId) async {
    final repository = ref.read(projectRepositoryProvider(userId));
    await repository.delete(projectId);
    await loadProjects();
  }

  Future<void> toggleProjectPin(String projectId, bool isPinned) async {
    final repository = ref.read(projectRepositoryProvider(userId));
    await repository.toggleProjectPin(projectId, isPinned);
    await loadProjects();
  }

  bool get showArchived => _showArchived;
}

final selectedProjectProvider = StateProvider<Project?>((ref) => null);

final projectDetailProvider = StateNotifierProvider.family<ProjectDetailNotifier, AsyncValue<Project?>, String>((ref, projectId) {
  return ProjectDetailNotifier(
    projectId: projectId,
    ref: ref,
  );
});

class ProjectDetailNotifier extends StateNotifier<AsyncValue<Project?>> {
  final String projectId;
  final ProviderRef ref;

  ProjectDetailNotifier({
    required this.projectId,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadProject();
  }

  Future<void> loadProject() async {
    state = const AsyncValue.loading();
    
    try {
      // Get userId from auth
      final userId = 'current_user_id'; // Will be replaced with actual userId
      final repository = ref.read(projectRepositoryProvider(userId));
      final project = await repository.getById(projectId);
      state = AsyncValue.data(project);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

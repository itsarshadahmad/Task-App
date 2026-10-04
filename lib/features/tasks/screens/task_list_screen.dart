import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/models/task_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/tasks/providers/task_provider.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/utils/app_helpers.dart';
import '../../../shared/widgets/app_text_field.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _searchController = TextEditingController();
  String _currentFilter = AppConstants.filterAll;
  bool _showCompleted = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              setState(() {});
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AppConstants.filterAll,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: AppConstants.filterToday,
                child: Text('Today'),
              ),
              const PopupMenuItem(
                value: AppConstants.filterUpcoming,
                child: Text('Upcoming'),
              ),
              const PopupMenuItem(
                value: AppConstants.filterOverdue,
                child: Text('Overdue'),
              ),
              const PopupMenuItem(
                value: AppConstants.filterPinned,
                child: Text('Pinned'),
              ),
              const PopupMenuItem(
                value: AppConstants.filterArchived,
                child: Text('Archived'),
              ),
            ],
            onSelected: (value) {
              setState(() => _currentFilter = value);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search_rounded),
              onChanged: (value) {
                // Will be handled by provider
              },
            ),
          ),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _currentFilter == AppConstants.filterAll,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _currentFilter = AppConstants.filterAll);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Today'),
                  selected: _currentFilter == AppConstants.filterToday,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _currentFilter = AppConstants.filterToday);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Upcoming'),
                  selected: _currentFilter == AppConstants.filterUpcoming,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _currentFilter = AppConstants.filterUpcoming);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Overdue'),
                  selected: _currentFilter == AppConstants.filterOverdue,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _currentFilter = AppConstants.filterOverdue);
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Show completed toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Switch(
                  value: _showCompleted,
                  onChanged: (value) => setState(() => _showCompleted = value),
                ),
                const SizedBox(width: 8),
                Text(
                  'Show completed',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Task list
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final taskState = ref.watch(taskListProvider('user_id'));
                
                return taskState.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                  data: (tasks) {
                    final filteredTasks = tasks.where((task) {
                      if (!_showCompleted && task.isCompleted) {
                        return false;
                      }
                      return true;
                    }).toList();
                    
                    if (filteredTasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks found',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first task to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: TaskCard(
                                  task: filteredTasks[index],
                                  onToggleComplete: () {
                                    ref.read(taskListProvider('user_id').notifier)
                                      .toggleTaskCompletion(
                                        filteredTasks[index].id,
                                        !filteredTasks[index].isCompleted,
                                      );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppHelpers.showTaskCreationDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

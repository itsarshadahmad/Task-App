import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/models/task_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/tasks/providers/task_provider.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/utils/app_helpers.dart';

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  final List<String> _columns = const [
    'To Do',
    'In Progress',
    'Review',
    'Done',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => AppHelpers.showTaskCreationDialog(context),
          ),
        ],
      ),
      body: Consumer(
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
              final todoTasks = tasks.where((t) => !t.isCompleted && t.priority == 0).toList();
              final inProgressTasks = tasks.where((t) => !t.isCompleted && t.priority > 0 && t.priority < 4).toList();
              final reviewTasks = tasks.where((t) => !t.isCompleted && t.priority == 4).toList();
              final doneTasks = tasks.where((t) => t.isCompleted).toList();
              
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_columns.length, (index) {
                    final columnTasks = _getTasksForColumn(index, todoTasks, inProgressTasks, reviewTasks, doneTasks);
                    
                    return AnimationLimiter(
                      child: _buildColumn(
                        theme,
                        colorScheme,
                        _columns[index],
                        columnTasks,
                        index,
                        ref,
                      ),
                    );
                  }),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Task> _getTasksForColumn(
    int columnIndex,
    List<Task> todo,
    List<Task> inProgress,
    List<Task> review,
    List<Task> done,
  ) {
    switch (columnIndex) {
      case 0:
        return todo;
      case 1:
        return inProgress;
      case 2:
        return review;
      case 3:
        return done;
      default:
        return [];
    }
  }

  Widget _buildColumn(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    List<Task> tasks,
    int index,
    WidgetRef ref,
  ) {
    final columnColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.surfaceContainerHighest,
    ];
    
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: columnColors[index % columnColors.length],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: TaskCard(
                          task: tasks[index],
                          showProject: false,
                          showTags: false,
                          onToggleComplete: () {
                            ref.read(taskListProvider('user_id').notifier)
                              .toggleTaskCompletion(
                                tasks[index].id,
                                !tasks[index].isCompleted,
                              );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

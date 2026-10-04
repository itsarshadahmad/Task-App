import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/models/task_model.dart';
import '../../../features/tasks/providers/task_provider.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/utils/app_helpers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
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
              final tasksWithDates = _getTasksByDate(tasks);
              
              return Column(
                children: [
                  // Calendar
                  TableCalendar<
                    DateTime,
                    Task,
                    DateTimeRange,
                  >(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() => _focusedDay = focusedDay);
                    },
                    calendarFormat: CalendarFormat.week,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronIcon: const Icon(Icons.chevron_left_rounded),
                      rightChevronIcon: const Icon(Icons.chevron_right_rounded),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: theme.textTheme.bodyMedium!,
                      weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                        color: colorScheme.error,
                      ),
                      selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                      todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      cellMargin: const EdgeInsets.all(4),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    eventLoader: (day) => tasksWithDates[day] ?? [],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Selected date tasks
                  if (_selectedDay != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: (tasksWithDates[_selectedDay] ?? []).length,
                        itemBuilder: (context, index) {
                          final task = (tasksWithDates[_selectedDay] ?? [])[index];
                          return TaskCard(
                            task: task,
                            showProject: false,
                            onToggleComplete: () {
                              ref.read(taskListProvider('user_id').notifier)
                                .toggleTaskCompletion(
                                  task.id,
                                  !task.isCompleted,
                                );
                            },
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Text(
                          'Select a date to view tasks',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppHelpers.showTaskCreationDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Map<DateTime, List<Task>> _getTasksByDate(List<Task> tasks) {
    final tasksByDate = <DateTime, List<Task>>{};
    
    for (final task in tasks) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        tasksByDate[date] = [...(tasksByDate[date] ?? []), task];
      }
    }
    
    return tasksByDate;
  }
}

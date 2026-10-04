import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../models/reminder_model.dart';

class AIService {
  final String userId;

  AIService({required this.userId});

  /// Analyzes tasks and suggests smart reminders
  List<Reminder> suggestReminders(List<Task> tasks) {
    final reminders = <Reminder>[];
    final now = DateTime.now();
    
    for (final task in tasks) {
      if (task.isCompleted || !task.hasReminders) continue;
      
      final dueDate = task.dueDate;
      if (dueDate == null) continue;
      
      final difference = dueDate.difference(now);
      
      // Suggest reminder based on task priority and due date
      if (task.priority >= 3) {
        // High/Urgent priority: remind 1 day and 2 hours before
        if (difference.inDays >= 1) {
          reminders.add(
            Reminder.create(
              dateTime: dueDate.subtract(const Duration(days: 1)),
              type: 'once',
              title: 'High priority task due tomorrow: ${task.title}',
              taskId: task.id,
              notifyBefore: true,
              notifyMinutesBefore: 1440, // 1 day
            ),
          );
        }
        
        reminders.add(
          Reminder.create(
            dateTime: dueDate.subtract(const Duration(hours: 2)),
            type: 'once',
            title: 'High priority task due in 2 hours: ${task.title}',
            taskId: task.id,
            notifyBefore: true,
            notifyMinutesBefore: 120,
          ),
        );
      } else if (task.priority >= 2) {
        // Medium priority: remind 1 day before
        if (difference.inDays >= 1) {
          reminders.add(
            Reminder.create(
              dateTime: dueDate.subtract(const Duration(days: 1)),
              type: 'once',
              title: 'Task due tomorrow: ${task.title}',
              taskId: task.id,
              notifyBefore: true,
              notifyMinutesBefore: 1440,
            ),
          );
        }
      } else if (task.priority >= 1) {
        // Low priority: remind on due date
        reminders.add(
          Reminder.create(
            dateTime: dueDate,
            type: 'once',
            title: 'Task due today: ${task.title}',
            taskId: task.id,
            notifyBefore: true,
            notifyMinutesBefore: 30,
          ),
        );
      }
    }
    
    return reminders;
  }

  /// Generates automated progress reports
  Map<String, dynamic> generateProgressReport(
    List<Task> tasks,
    List<Task> completedTasks,
  ) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    // Weekly progress
    final weeklyCompleted = completedTasks.where((task) {
      return task.completedAt != null &&
             task.completedAt!.isAfter(startOfWeek) &&
             task.completedAt!.isBefore(endOfWeek);
    }).length;
    
    final weeklyCreated = tasks.where((task) {
      return task.createdAt != null &&
             task.createdAt!.isAfter(startOfWeek) &&
             task.createdAt!.isBefore(endOfWeek);
    }).length;
    
    // Overdue tasks
    final overdueTasks = tasks.where((task) {
      return !task.isCompleted &&
             task.dueDate != null &&
             task.dueDate!.isBefore(now);
    }).length;
    
    // Upcoming tasks
    final upcomingTasks = tasks.where((task) {
      return !task.isCompleted &&
             task.dueDate != null &&
             task.dueDate!.isAfter(now);
    }).length;
    
    // Calculate completion rate
    final totalTasks = tasks.length;
    final completedCount = completedTasks.length;
    final completionRate = totalTasks > 0 ? (completedCount / totalTasks * 100) : 0;
    
    // Calculate average time to complete
    double avgCompletionTime = 0;
    int completedWithDates = 0;
    
    for (final task in completedTasks) {
      if (task.createdAt != null && task.completedAt != null) {
        final duration = task.completedAt!.difference(task.createdAt!);
        avgCompletionTime += duration.inHours;
        completedWithDates++;
      }
    }
    
    avgCompletionTime = completedWithDates > 0 
      ? avgCompletionTime / completedWithDates 
      : 0;
    
    return {
      'weekly_completed': weeklyCompleted,
      'weekly_created': weeklyCreated,
      'overdue_tasks': overdueTasks,
      'upcoming_tasks': upcomingTasks,
      'completion_rate': completionRate,
      'avg_completion_time_hours': avgCompletionTime,
      'total_tasks': totalTasks,
      'completed_tasks': completedCount,
    };
  }

  /// Suggests tasks to focus on based on priority and due dates
  List<Task> suggestFocusTasks(List<Task> tasks) {
    final now = DateTime.now();
    
    return tasks
      .where((task) => !task.isCompleted)
      .toList()
      ..sort((a, b) {
        // Sort by due date (sooner first)
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        
        // Then by priority (higher first)
        return b.priority.compareTo(a.priority);
      })
      .take(5) // Top 5 tasks to focus on
      .toList();
  }

  /// Generates smart categories based on task patterns
  Map<String, List<Task>> categorizeTasks(List<Task> tasks) {
    final categories = <String, List<Task>>{};
    
    for (final task in tasks) {
      if (task.dueDate != null) {
        final now = DateTime.now();
        final difference = task.dueDate!.difference(now);
        
        if (difference.isNegative) {
          categories.putIfAbsent('Overdue', () => []).add(task);
        } else if (difference.inDays == 0) {
          categories.putIfAbsent('Today', () => []).add(task);
        } else if (difference.inDays <= 7) {
          categories.putIfAbsent('This Week', () => []).add(task);
        } else if (difference.inDays <= 30) {
          categories.putIfAbsent('This Month', () => []).add(task);
        } else {
          categories.putIfAbsent('Future', () => []).add(task);
        }
      } else {
        categories.putIfAbsent('No Due Date', () => []).add(task);
      }
    }
    
    return categories;
  }

  /// Analyzes productivity patterns
  Map<String, dynamic> analyzeProductivity(List<Task> completedTasks) {
    final productivityByDay = <String, int>{};
    final productivityByHour = <int, int>{};
    
    for (final task in completedTasks) {
      if (task.completedAt != null) {
        // By day of week
        final dayName = DateFormat.EEEE().format(task.completedAt!);
        productivityByDay[dayName] = (productivityByDay[dayName] ?? 0) + 1;
        
        // By hour of day
        final hour = task.completedAt!.hour;
        productivityByHour[hour] = (productivityByHour[hour] ?? 0) + 1;
      }
    }
    
    // Find most productive day
    String mostProductiveDay = '';
    int maxDayCount = 0;
    
    for (final entry in productivityByDay.entries) {
      if (entry.value > maxDayCount) {
        maxDayCount = entry.value;
        mostProductiveDay = entry.key;
      }
    }
    
    // Find most productive hour
    int mostProductiveHour = 0;
    int maxHourCount = 0;
    
    for (final entry in productivityByHour.entries) {
      if (entry.value > maxHourCount) {
        maxHourCount = entry.value;
        mostProductiveHour = entry.key;
      }
    }
    
    return {
      'productivity_by_day': productivityByDay,
      'productivity_by_hour': productivityByHour,
      'most_productive_day': mostProductiveDay,
      'most_productive_hour': mostProductiveHour,
      'total_completed': completedTasks.length,
    };
  }
}

final aiServiceProvider = Provider.family<AIService, String>((ref, userId) {
  return AIService(userId: userId);
});

// Helper for date formatting
class DateFormat {
  static String EEEE() => 'EEEE';
}

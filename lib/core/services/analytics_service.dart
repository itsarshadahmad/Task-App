import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../models/project_model.dart';

class AnalyticsService {
  final String userId;

  AnalyticsService({required this.userId});

  Map<String, int> calculateTaskCompletionStats(List<Task> tasks) {
    int completed = 0;
    int incomplete = 0;
    int overdue = 0;
    int today = 0;
    int upcoming = 0;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day + 1);

    for (final task in tasks) {
      if (task.isCompleted) {
        completed++;
      } else {
        incomplete++;
        
        if (task.dueDate != null) {
          if (task.dueDate!.isBefore(now)) {
            overdue++;
          } else if (task.dueDate!.isAfter(startOfDay) && 
                     task.dueDate!.isBefore(endOfDay)) {
            today++;
          } else if (task.dueDate!.isAfter(now)) {
            upcoming++;
          }
        }
      }
    }

    return {
      'completed': completed,
      'incomplete': incomplete,
      'overdue': overdue,
      'today': today,
      'upcoming': upcoming,
    };
  }

  Map<String, int> calculatePriorityStats(List<Task> tasks) {
    int priority0 = 0;
    int priority1 = 0;
    int priority2 = 0;
    int priority3 = 0;
    int priority4 = 0;

    for (final task in tasks) {
      switch (task.priority) {
        case 0:
          priority0++;
          break;
        case 1:
          priority1++;
          break;
        case 2:
          priority2++;
          break;
        case 3:
          priority3++;
          break;
        case 4:
          priority4++;
          break;
      }
    }

    return {
      'none': priority0,
      'low': priority1,
      'medium': priority2,
      'high': priority3,
      'urgent': priority4,
    };
  }

  Map<String, double> calculateProjectProgressStats(List<Project> projects) {
    int totalProjects = projects.length;
    int completedProjects = 0;
    int inProgressProjects = 0;
    int notStartedProjects = 0;
    double overallProgress = 0;

    for (final project in projects) {
      if (project.isComplete) {
        completedProjects++;
      } else if (project.taskCount > 0) {
        if (project.completedTaskCount > 0) {
          inProgressProjects++;
        } else {
          notStartedProjects++;
        }
      } else {
        notStartedProjects++;
      }
      
      overallProgress += project.progress;
    }

    return {
      'total': totalProjects.toDouble(),
      'completed': completedProjects.toDouble(),
      'in_progress': inProgressProjects.toDouble(),
      'not_started': notStartedProjects.toDouble(),
      'overall_progress': totalProjects > 0 ? overallProgress / totalProjects : 0,
    };
  }

  Map<String, int> calculateTimeEstimationStats(List<Task> tasks) {
    double totalEstimated = 0;
    double totalActual = 0;
    int tasksWithEstimation = 0;

    for (final task in tasks) {
      if (task.estimatedHours > 0) {
        totalEstimated += task.estimatedHours;
        totalActual += task.actualHours;
        tasksWithEstimation++;
      }
    }

    return {
      'tasks_with_estimation': tasksWithEstimation,
      'total_estimated_hours': totalEstimated.toInt(),
      'total_actual_hours': totalActual.toInt(),
    };
  }

  Map<DateTime, int> calculateDailyCompletionStats(List<Task> tasks) {
    final stats = <DateTime, int>{};
    
    for (final task in tasks) {
      if (task.isCompleted && task.completedAt != null) {
        final date = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );
        stats[date] = (stats[date] ?? 0) + 1;
      }
    }

    return stats;
  }

  Map<String, int> calculateTagUsageStats(List<Task> tasks) {
    final stats = <String, int>{};
    
    for (final task in tasks) {
      for (final tagId in task.tagIds) {
        stats[tagId] = (stats[tagId] ?? 0) + 1;
      }
    }

    return stats;
  }
}

final analyticsServiceProvider = Provider.family<AnalyticsService, String>((ref, userId) {
  return AnalyticsService(userId: userId);
});

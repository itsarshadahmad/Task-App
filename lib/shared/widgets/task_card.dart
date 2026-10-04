import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/task_model.dart';
import '../../core/constants/app_constants.dart';
import '../utils/app_helpers.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onPin;
  final bool showProject;
  final bool showTags;
  final bool showDueDate;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.onEdit,
    this.onPin,
    this.showProject = true,
    this.showTags = true,
    this.showDueDate = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final priorityColor = _getPriorityColor(colorScheme);
    final dueDateColor = _getDueDateColor(colorScheme);
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.primary,
              icon: Icons.edit_outlined,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.error,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        elevation: 0,
        color: task.color != null 
          ? Color(int.parse(task.color!.replaceAll('#', '0xFF'))) 
          : colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) => onToggleComplete?.call(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(
                        color: colorScheme.outline,
                      ),
                      activeColor: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    
                    // Title
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted 
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                          color: task.isCompleted 
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Pin icon
                    if (task.isPinned)
                      Icon(
                        Icons.push_pin_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                  ],
                ),
                
                if (task.description != null && task.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 36, top: 4),
                    child: Text(
                      task.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Metadata row
                Row(
                  children: [
                    if (showDueDate && task.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: dueDateColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppHelpers.formatDate(task.dueDate!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: dueDateColor,
                            ),
                          ),
                        ],
                      ),
                    
                    if (showDueDate && task.dueDate != null && showProject)
                      const SizedBox(width: 12),
                    
                    if (showProject)
                      Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Project', // Will be replaced with actual project name
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    
                    if (task.priority > AppConstants.priorityNone)
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 16,
                            color: priorityColor,
                          ),
                        ],
                      ),
                    
                    // Progress indicator for subtasks
                    if (task.hasSubtasks)
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: LinearProgressIndicator(
                              value: task.progress,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                if (showTags && task.tagIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 36, top: 8),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: task.tagIds.map((tagId) => 
                        Chip(
                          label: Text(
                            'Tag $tagId', // Will be replaced with actual tag name
                            style: theme.textTheme.bodySmall,
                          ),
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.primary,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        )
                      ).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(ColorScheme colorScheme) {
    switch (task.priority) {
      case 1:
        return colorScheme.tertiary;
      case 2:
        return colorScheme.secondary;
      case 3:
        return colorScheme.error;
      case 4:
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  Color _getDueDateColor(ColorScheme colorScheme) {
    if (task.isCompleted) {
      return colorScheme.onSurfaceVariant;
    }
    
    final dueDate = task.dueDate;
    if (dueDate == null) {
      return colorScheme.onSurfaceVariant;
    }
    
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      return colorScheme.error;
    } else if (difference.inDays <= 1) {
      return colorScheme.error;
    } else if (difference.inDays <= 3) {
      return colorScheme.tertiary;
    }
    
    return colorScheme.onSurfaceVariant;
  }
}

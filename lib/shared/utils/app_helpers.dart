import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/task_model.dart';
import '../../core/models/project_model.dart';
import '../../core/constants/app_constants.dart';

class AppHelpers {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.isNegative) {
      if (difference.inDays >= -1) {
        return 'Yesterday';
      } else if (difference.inDays >= -7) {
        return DateFormat.EEEE().format(date);
      }
      return DateFormat(AppConstants.dateFormatMedium).format(date);
    }
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return DateFormat.EEEE().format(date);
    }
    
    return DateFormat(AppConstants.dateFormatMedium).format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  static String getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Urgent';
      default:
        return 'None';
    }
  }

  static Color getPriorityColor(BuildContext context, int priority) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (priority) {
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

  static String getTaskStatus(Task task) {
    if (task.isCompleted) return 'Completed';
    if (task.dueDate != null && task.dueDate!.isBefore(DateTime.now())) {
      return 'Overdue';
    }
    if (task.dueDate != null) {
      final difference = task.dueDate!.difference(DateTime.now());
      if (difference.inDays <= 1) {
        return 'Due soon';
      }
    }
    return 'Active';
  }

  static String getProjectProgressText(Project project) {
    if (project.taskCount == 0) return '0%';
    final percentage = (project.progress * 100).toInt();
    return '$percentage%';
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showTaskCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TaskCreationDialog(),
    );
  }
}

class TaskCreationDialog extends StatefulWidget {
  const TaskCreationDialog({super.key});

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int _priority = 0;
  DateTime? _dueDate;
  String? _projectId;
  List<String> _tagIds = [];
  String? _color;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    final task = Task.create(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      projectId: _projectId,
      color: _color,
    );
    
    // TODO: Save task
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Task',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'What needs to be done?',
                  prefixIcon: const Icon(Icons.title_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length > AppConstants.maxTitleLength) {
                    return 'Title is too long';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add details...',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                maxLength: AppConstants.maxDescriptionLength,
              ),
              
              const SizedBox(height: 16),
              
              // Due date
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        hintText: 'Select a date',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: _selectDate,
                      controller: TextEditingController(
                        text: _dueDate != null 
                          ? AppHelpers.formatDate(_dueDate!)
                          : '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Priority
                  DropdownButton<int>(
                    value: _priority,
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('None'),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Low'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('High'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('Urgent'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                    underline: Container(),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

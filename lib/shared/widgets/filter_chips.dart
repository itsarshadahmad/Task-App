import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class FilterChipBar extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChipBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar> {
  final List<String> _filters = const [
    AppConstants.filterAll,
    AppConstants.filterToday,
    AppConstants.filterUpcoming,
    AppConstants.filterOverdue,
    AppConstants.filterPinned,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = widget.selectedFilter == filter;
          final label = _getFilterLabel(filter);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(filter);
                }
              },
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primaryContainer,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
              checkmarkColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case AppConstants.filterAll:
        return 'All';
      case AppConstants.filterToday:
        return 'Today';
      case AppConstants.filterUpcoming:
        return 'Upcoming';
      case AppConstants.filterOverdue:
        return 'Overdue';
      case AppConstants.filterPinned:
        return 'Pinned';
      case AppConstants.filterCompleted:
        return 'Completed';
      case AppConstants.filterIncomplete:
        return 'Incomplete';
      case AppConstants.filterArchived:
        return 'Archived';
      default:
        return filter;
    }
  }
}

class PriorityFilterChips extends StatefulWidget {
  final int selectedPriority;
  final ValueChanged<int> onPriorityChanged;

  const PriorityFilterChips({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  State<PriorityFilterChips> createState() => _PriorityFilterChipsState();
}

class _PriorityFilterChipsState extends State<PriorityFilterChips> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildPriorityChip(0, 'None', Colors.grey, theme, colorScheme),
          const SizedBox(width: 8),
          _buildPriorityChip(1, 'Low', Colors.green, theme, colorScheme),
          const SizedBox(width: 8),
          _buildPriorityChip(2, 'Medium', Colors.orange, theme, colorScheme),
          const SizedBox(width: 8),
          _buildPriorityChip(3, 'High', Colors.red, theme, colorScheme),
          const SizedBox(width: 8),
          _buildPriorityChip(4, 'Urgent', Colors.red, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(
    int priority,
    String label,
    Color color,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = widget.selectedPriority == priority;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          widget.onPriorityChanged(priority);
        }
      },
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: color.withOpacity(0.2),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected ? color : colorScheme.onSurface,
      ),
      checkmarkColor: color,
      avatar: Icon(
        Icons.flag_rounded,
        size: 16,
        color: color,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

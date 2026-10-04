import 'package:flutter/material.dart';

class CircularProgressWidget extends StatelessWidget {
  final double value;
  final double? size;
  final Color? backgroundColor;
  final Color? color;
  final double strokeWidth;
  final Widget? child;

  const CircularProgressWidget({
    super.key,
    required this.value,
    this.size,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 4.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
            color: color ?? colorScheme.primary,
            strokeWidth: strokeWidth,
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class LinearProgressWidget extends StatelessWidget {
  final double value;
  final double? height;
  final Color? backgroundColor;
  final Color? color;
  final double borderRadius;

  const LinearProgressWidget({
    super.key,
    required this.value,
    this.height,
    this.backgroundColor,
    this.color,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
          color: color ?? colorScheme.primary,
        ),
      ),
    );
  }
}

class TaskProgressIndicator extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final double? size;

  const TaskProgressIndicator({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressWidget(
          value: progress,
          size: size,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$completedTasks/$totalTasks',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

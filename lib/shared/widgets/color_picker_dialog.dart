import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class ColorPickerDialog extends StatefulWidget {
  final String? initialColor;
  final ValueChanged<String> onColorSelected;

  const ColorPickerDialog({
    super.key,
    this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  String _selectedColor = AppConstants.defaultColors[0];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor ?? AppConstants.defaultColors[0];
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Color',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Color grid
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: AppConstants.defaultColors.length,
              itemBuilder: (context, index) {
                final color = AppConstants.defaultColors[index];
                final colorValue = Color(int.parse(color.replaceAll('#', '0xFF')));
                final isSelected = _selectedColor == color;
                
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    widget.onColorSelected(color);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorValue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: colorValue.computeLuminance() > 0.5 
                            ? Colors.black 
                            : Colors.white,
                        )
                      : null,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Custom color picker
            Text(
              'Custom Color',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Color picker preview
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Color(int.parse(_selectedColor.replaceAll('#', '0xFF'))),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Center(
                child: Text(
                  _selectedColor.toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Color(int.parse(_selectedColor.replaceAll('#', '0xFF'))).computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Close button
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

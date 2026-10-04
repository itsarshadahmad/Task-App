import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String? hintText;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText,
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.controller?.text ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasFocus ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  widget.controller?.text = value;
                  widget.onChanged?.call(value);
                },
                onSubmitted: widget.onSubmitted,
                autofocus: widget.autofocus,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Search...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.controller?.clear();
                  widget.onClear?.call();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
            ? Border.all(
                color: borderColor ?? colorScheme.primary,
                width: borderWidth,
              )
            : null,
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackAvatar(colorScheme);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                ),
              );
            },
          ),
        ),
      );
    }
    
    return _buildFallbackAvatar(colorScheme);
  }

  Widget _buildFallbackAvatar(ColorScheme colorScheme) {
    final initials = name != null && name!.isNotEmpty
      ? name!.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join()
      : '?';
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? colorScheme.primaryContainer,
        border: showBorder
          ? Border.all(
              color: borderColor ?? colorScheme.primary,
              width: borderWidth,
            )
          : null,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: textColor ?? colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class GroupAvatar extends StatelessWidget {
  final List<String> imageUrls;
  final List<String>? names;
  final double size;
  final int maxAvatars;

  const GroupAvatar({
    super.key,
    required this.imageUrls,
    this.names,
    this.size = 40,
    this.maxAvatars = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (imageUrls.isEmpty) {
      return AvatarWidget(size: size);
    }
    
    final avatars = imageUrls.take(maxAvatars - 1).toList();
    final remaining = imageUrls.length - (maxAvatars - 1);
    
    return Stack(
      children: [
        ...avatars.asMap().entries.map((entry) {
          return Positioned(
            left: entry.key * (size * 0.7),
            child: AvatarWidget(
              imageUrl: entry.value,
              name: names != null && names!.length > entry.key ? names![entry.key] : null,
              size: size,
              showBorder: true,
              borderColor: colorScheme.surface,
              borderWidth: 2,
            ),
          );
        }),
        if (remaining > 0)
          Positioned(
            left: (maxAvatars - 1) * (size * 0.7),
            child: AvatarWidget(
              name: '+$remaining',
              size: size,
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              showBorder: true,
              borderColor: colorScheme.surface,
              borderWidth: 2,
            ),
          ),
      ],
    );
  }
}

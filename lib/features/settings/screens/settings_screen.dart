import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          
          _buildListTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                );
              },
            ),
          ),
          
          _buildListTile(
            context,
            icon: Icons.brightness_auto_outlined,
            title: 'System Theme',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.themeMode == ThemeMode.system,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setThemeMode(
                      value ? ThemeMode.system : ThemeMode.light,
                    );
                  },
                );
              },
            ),
          ),
          
          _buildListTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Dynamic Colors',
            subtitle: 'Use Material You dynamic colors',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.useDynamicColors,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setUseDynamicColors(value);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          
          _buildListTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Task Reminders',
            subtitle: 'Get notified about upcoming tasks',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.enableNotifications,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setEnableNotifications(value);
                  },
                );
              },
            ),
          ),
          
          _buildListTile(
            context,
            icon: Icons.vibration_outlined,
            title: 'Haptic Feedback',
            subtitle: 'Enable vibration for interactions',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.enableHaptics,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setEnableHaptics(value);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sync section
          _buildSectionHeader(context, 'Sync & Backup'),
          
          _buildListTile(
            context,
            icon: Icons.cloud_outlined,
            title: 'Cloud Sync',
            subtitle: 'Sync data across devices',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.enableCloudSync,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setEnableCloudSync(value);
                  },
                );
              },
            ),
          ),
          
          _buildListTile(
            context,
            icon: Icons.sync_outlined,
            title: 'Auto Sync',
            subtitle: 'Automatically sync when online',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.autoSync,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setAutoSync(value);
                  },
                );
              },
            ),
          ),
          
          _buildListTile(
            context,
            icon: Icons.backup_outlined,
            title: 'End-to-End Encryption',
            subtitle: 'Encrypt your data for privacy',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.enableEncryption,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setEnableEncryption(value);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice section
          _buildSectionHeader(context, 'Voice'),
          
          _buildListTile(
            context,
            icon: Icons.mic_outlined,
            title: 'Voice to Text',
            subtitle: 'Create tasks with your voice',
            trailing: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(settingsProvider);
                return Switch(
                  value: settings.enableVoiceInput,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setEnableVoiceInput(value);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About section
          _buildSectionHeader(context, 'About'),
          
          _buildListTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'About Task App',
            onTap: () {
              // Navigate to about page
            },
          ),
          
          _buildListTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          
          _buildListTile(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help page
            },
          ),
          
          const SizedBox(height: 16),
          
          // Account section
          _buildSectionHeader(context, 'Account'),
          
          _buildListTile(
            context,
            icon: Icons.manage_accounts_outlined,
            title: 'Manage Account',
            onTap: () {
              // Navigate to account settings
            },
          ),
          
          _buildListTile(
            context,
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            textColor: colorScheme.error,
            onTap: () async {
              // Sign out
              // await ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
          
          const SizedBox(height: 24),
          
          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor ?? colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
        ? Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        : null,
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

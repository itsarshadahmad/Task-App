import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/board/screens/board_screen.dart';
import 'features/tasks/screens/task_list_screen.dart';
import 'features/projects/screens/project_list_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'shared/widgets/main_scaffold.dart';

class TaskApp extends ConsumerWidget {
  final ColorScheme? lightColorScheme;
  final ColorScheme? darkColorScheme;

  const TaskApp({
    super.key,
    this.lightColorScheme,
    this.darkColorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TaskListScreen(),
            ),
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TaskListScreen(),
            ),
            GoRoute(
              path: '/board',
              builder: (context, state) => const BoardScreen(),
            ),
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
            GoRoute(
              path: '/projects',
              builder: (context, state) => const ProjectListScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = ref.read(authProvider).isAuthenticated;
        final isSplash = state.location == '/splash';
        
        if (!isLoggedIn && !isSplash) {
          return '/login';
        }
        
        if (isLoggedIn && state.location == '/login') {
          return '/';
        }
        
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Task App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(lightColorScheme),
      darkTheme: AppTheme.darkTheme(darkColorScheme),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
      ],
    );
  }
}

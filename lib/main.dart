import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_env.dart';
import 'presentation/screens/task_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  runApp(const ProviderScope(child: TaskTrackerApp()));
}

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF1746A2),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF1746A2),
          secondary: const Color(0xFFE76F51),
          surface: Colors.white,
        );
    final baseTextTheme = ThemeData(brightness: Brightness.light).textTheme;

    return MaterialApp(
      title: 'Pelacak Tugas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF8F6F1),
        useMaterial3: true,
        textTheme: baseTextTheme.copyWith(
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            color: const Color(0xFF111827),
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            color: const Color(0xFF111827),
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: const Color(0xFF111827),
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            color: const Color(0xFF111827),
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            color: const Color(0xFF1F2937),
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            color: const Color(0xFF334155),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9DDE5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9DDE5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1746A2), width: 1.4),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.92),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE76F51),
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1746A2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const TaskListPage(),
    );
  }
}

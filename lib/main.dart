import 'package:flutter/material.dart';

import 'models/task.dart';
import 'state/task_store.dart';
import 'widgets/task_progress_indicator.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PocketTasksApp());
}

class PocketTasksApp extends StatefulWidget {
  const PocketTasksApp({super.key});

  @override
  State<PocketTasksApp> createState() => _PocketTasksAppState();
}

class _PocketTasksAppState extends State<PocketTasksApp> {
  final TaskStore store = TaskStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF290559), brightness: Brightness.dark),
      scaffoldBackgroundColor: ColorScheme.fromSeed(seedColor: const Color(0xFF290559), brightness: Brightness.light).surface,
      useMaterial3: true,
    );
 
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF290559), brightness: Brightness.light),
      scaffoldBackgroundColor: ColorScheme.fromSeed(seedColor: const Color(0xFF290559), brightness: Brightness.light).surface,
      useMaterial3: true,
    );


    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          title: 'PocketTasks',
          themeMode: ThemeMode.system,
          theme: light,
          darkTheme: dark,
          home: HomeScreen(store: store),
        );
      },
    );
  }
}



import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';

class TaskStore extends ChangeNotifier {
  static const String storageKey = 'pocket_tasks_v1';

  final List<Task> _tasks = <Task>[];
  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskFilter _filter = TaskFilter.all;
  TaskFilter get filter => _filter;

  String _query = '';
  String get query => _query;

  Timer? _debounce;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  List<Task> get visibleTasks => applyQueryAndFilter(_tasks, _filter, _query);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString(storageKey);
    if (source != null) {
      final list = Task.decodeList(source);
      _tasks
        ..clear()
        ..addAll(list);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TaskStore.storageKey, Task.encodeList(_tasks));
  }

  Future<Task> addTask(String title) async {
    final id = const Uuid().v4();
    final task = Task(
      id: id,
      title: title.trim(),
      done: false,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    await _persist();
    notifyListeners();
    return task;
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    _tasks[index] = task.copyWith(done: !task.done);
    await _persist();
    notifyListeners();
  }

  Future<Task?> removeById(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final removed = _tasks.removeAt(index);
    await _persist();
    notifyListeners();
    return removed;
  }

  Future<void> insertAt(int index, Task task) async {
    if (index < 0 || index > _tasks.length) {
      _tasks.add(task);
    } else {
      _tasks.insert(index, task);
    }
    await _persist();
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setQueryDebounced(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = query;
      notifyListeners();
    });
  }

  int get completedCount => _tasks.where((t) => t.done).length;
}


import 'dart:convert';

class Task {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.done,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? done,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      done: json['done'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static String encodeList(List<Task> tasks) {
    final data = tasks.map((t) => t.toJson()).toList(growable: false);
    return jsonEncode(data);
  }

  static List<Task> decodeList(String source) {
    final data = jsonDecode(source) as List<dynamic>;
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }
}

enum TaskFilter { all, active, done }

List<Task> applyQueryAndFilter(List<Task> tasks, TaskFilter filter, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  Iterable<Task> result = tasks;

  switch (filter) {
    case TaskFilter.active:
      result = result.where((t) => !t.done);
      break;
    case TaskFilter.done:
      result = result.where((t) => t.done);
      break;
    case TaskFilter.all:
      break;
  }

  if (normalizedQuery.isNotEmpty) {
    result = result.where((t) => t.title.toLowerCase().contains(normalizedQuery));
  }

  // Stable sort by createdAt ascending to keep UX predictable
  final sorted = result.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return sorted;
}


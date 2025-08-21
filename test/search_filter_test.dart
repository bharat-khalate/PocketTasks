import 'package:flutter_test/flutter_test.dart';

import 'package:pocketnotes/models/task.dart';

void main() {
  group('applyQueryAndFilter', () {
    final tasks = <Task>[
      Task(id: '1', title: 'Buy groceries', done: true, createdAt: DateTime(2024, 1, 1)),
      Task(id: '2', title: 'Walk the dog', done: false, createdAt: DateTime(2024, 1, 2)),
      Task(id: '3', title: 'Call Alice', done: false, createdAt: DateTime(2024, 1, 3)),
      Task(id: '4', title: 'Email Bob', done: true, createdAt: DateTime(2024, 1, 4)),
    ];

    test('All filter shows all, sorted by createdAt', () {
      final result = applyQueryAndFilter(tasks, TaskFilter.all, '');
      expect(result.length, 4);
      expect(result.first.id, '1');
      expect(result.last.id, '4');
    });

    test('Active filter shows only not done', () {
      final result = applyQueryAndFilter(tasks, TaskFilter.active, '');
      expect(result.map((t) => t.id), ['2', '3']);
    });

    test('Done filter shows only done', () {
      final result = applyQueryAndFilter(tasks, TaskFilter.done, '');
      expect(result.map((t) => t.id), ['1', '4']);
    });

    test('Query filters by title case-insensitive and trimmed', () {
      final result = applyQueryAndFilter(tasks, TaskFilter.all, '  DOG  ');
      expect(result.map((t) => t.id), ['2']);
    });
  });
}




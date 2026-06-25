import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker/data/api_exception.dart';
import 'package:task_tracker/data/paginated_tasks.dart';
import 'package:task_tracker/data/repository/task_repository.dart';
import 'package:task_tracker/data/task.dart';
import 'package:task_tracker/main.dart';
import 'package:task_tracker/presentation/providers/task_providers.dart';

void main() {
  testWidgets('renders task list from repository', (tester) async {
    await tester.pumpWidget(_appWithRepository(_FakeTaskRepository()));
    await tester.pumpAndSettle();
    await _scrollUntilVisible(tester, find.text('Belajar Riverpod'));
    await _scrollUntilVisible(tester, find.text('Rapikan backlog mobile'));

    expect(find.text('Task Tracker'), findsOneWidget);
    expect(find.text('Belajar Riverpod'), findsOneWidget);
    expect(find.text('Rapikan backlog mobile'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text('Sambungkan API detail'), findsNothing);
    expect(find.textContaining('Sort:'), findsOneWidget);
  });

  testWidgets('renders explicit status on task detail page', (tester) async {
    await tester.pumpWidget(_appWithRepository(_FakeTaskRepository()));
    await tester.pumpAndSettle();
    await _scrollUntilVisible(tester, find.text('Belajar Riverpod'));

    await tester.tap(find.text('Belajar Riverpod'));
    await tester.pumpAndSettle();

    expect(find.text('Task Detail'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);
  });

  testWidgets('switches between pending and done tabs', (tester) async {
    await tester.pumpWidget(_appWithRepository(_FakeTaskRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await _scrollUntilVisible(tester, find.text('Sambungkan API detail'));

    expect(find.text('Sambungkan API detail'), findsOneWidget);
    expect(find.text('Belajar Riverpod'), findsNothing);
  });

  testWidgets('filters task list by search query', (tester) async {
    await tester.pumpWidget(_appWithRepository(_FakeTaskRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Riverpod');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await _scrollUntilVisible(tester, find.text('Belajar Riverpod'));

    expect(find.text('Belajar Riverpod'), findsOneWidget);
    expect(find.text('Tidak ada task pending'), findsNothing);
  });

  testWidgets('changes sorting order from newest to title a-z', (tester) async {
    await tester.pumpWidget(_appWithRepository(_FakeTaskRepository()));
    await tester.pumpAndSettle();
    await _scrollUntilVisible(tester, find.text('Rapikan backlog mobile'));
    await _scrollUntilVisible(tester, find.text('Belajar Riverpod'));

    var cards = find.byType(Card);
    expect(
      find.descendant(
        of: cards.at(0),
        matching: find.text('Rapikan backlog mobile'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Sort: Newest first'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title A-Z').last);
    await tester.pumpAndSettle();
    await _scrollUntilVisible(tester, find.text('Belajar Riverpod'));
    await _scrollUntilVisible(tester, find.text('Rapikan backlog mobile'));

    cards = find.byType(Card);
    expect(
      find.descendant(of: cards.at(0), matching: find.text('Belajar Riverpod')),
      findsOneWidget,
    );
  });

  testWidgets('renders loading state while tasks are requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTaskRepository(fetchTasksCompleter: Completer<List<Task>>()),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state when repository returns no task', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithRepository(_FakeTaskRepository(tasks: [])));
    await tester.pumpAndSettle();
    await _scrollUntilVisible(tester, find.text('Tidak ada task pending'));

    expect(find.text('Tidak ada task pending'), findsOneWidget);
  });

  testWidgets('renders API error state', (tester) async {
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTaskRepository(error: const ApiException('Server is unavailable')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load tasks'), findsOneWidget);
    expect(find.text('Server is unavailable'), findsOneWidget);
  });

  testWidgets('validates add task form', (tester) async {
    await tester.pumpWidget(_appWithRepository(_FakeTaskRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save task'));
    await tester.pump();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
  });
}

Future<void> _scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  double delta = 300,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Widget _appWithRepository(TaskRepository repository) {
  return ProviderScope(
    overrides: [taskRepositoryProvider.overrideWithValue(repository)],
    child: const TaskTrackerApp(),
  );
}

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository({List<Task>? tasks, this.error, this.fetchTasksCompleter})
    : _tasks = tasks ?? _defaultTasks;

  static final _now = DateTime.utc(2026, 6, 25, 1, 40);
  static final _defaultTasks = [
    Task(
      id: 1,
      title: 'Belajar Riverpod',
      description: 'Pelajari state management untuk halaman daftar task.',
      status: TaskStatus.pending,
      createdAt: _now,
      updatedAt: _now,
    ),
    Task(
      id: 3,
      title: 'Rapikan backlog mobile',
      description: 'Pisahkan task mendesak dan task nice to have.',
      status: TaskStatus.pending,
      createdAt: _now.add(const Duration(minutes: 15)),
      updatedAt: _now.add(const Duration(minutes: 15)),
    ),
    Task(
      id: 2,
      title: 'Sambungkan API detail',
      description: 'Tampilkan detail task saat item dipilih.',
      status: TaskStatus.done,
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  final ApiException? error;
  final Completer<List<Task>>? fetchTasksCompleter;
  List<Task> _tasks;

  @override
  Future<PaginatedTasks> fetchTasks({
    int page = 1,
    int perPage = 20,
    String? search,
    TaskStatus? status,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  }) async {
    if (fetchTasksCompleter != null) {
      final tasks = await fetchTasksCompleter!.future;
      return PaginatedTasks(tasks: tasks, currentPage: page, lastPage: page);
    }
    if (error != null) {
      throw error!;
    }
    final normalizedSearch = search?.trim().toLowerCase();
    final filteredTasks =
        _tasks.where((task) {
          final matchesStatus = status == null || task.status == status;
          final matchesSearch =
              normalizedSearch == null ||
              normalizedSearch.isEmpty ||
              task.title.toLowerCase().contains(normalizedSearch);
          return matchesStatus && matchesSearch;
        }).toList()..sort((left, right) {
          final comparison = switch (sortBy) {
            'title' => left.title.toLowerCase().compareTo(
              right.title.toLowerCase(),
            ),
            _ => left.createdAt.compareTo(right.createdAt),
          };
          return sortDirection == 'asc' ? comparison : -comparison;
        });
    final start = (page - 1) * perPage;
    final end = start + perPage;
    final pagedTasks = filteredTasks.sublist(
      start.clamp(0, filteredTasks.length),
      end.clamp(0, filteredTasks.length),
    );
    final lastPage = filteredTasks.isEmpty
        ? 1
        : ((filteredTasks.length - 1) ~/ perPage) + 1;
    return PaginatedTasks(
      tasks: pagedTasks,
      currentPage: page,
      lastPage: lastPage,
    );
  }

  @override
  Future<Task> fetchTask(int id) async {
    return _tasks.firstWhere((task) => task.id == id);
  }

  @override
  Future<Task> createTask({
    required String title,
    required String description,
  }) async {
    final task = Task(
      id: _tasks.length + 1,
      title: title,
      description: description,
      status: TaskStatus.pending,
      createdAt: _now,
      updatedAt: _now,
    );
    _tasks = [..._tasks, task];
    return task;
  }

  @override
  Future<Task> updateStatus({
    required int id,
    required TaskStatus status,
  }) async {
    final task = _tasks
        .firstWhere((item) => item.id == id)
        .copyWith(status: status, updatedAt: _now);
    _tasks = [
      for (final item in _tasks)
        if (item.id == id) task else item,
    ];
    return task;
  }
}

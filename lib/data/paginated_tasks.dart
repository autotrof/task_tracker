import 'task.dart';

class PaginatedTasks {
  const PaginatedTasks({
    required this.tasks,
    required this.currentPage,
    required this.lastPage,
  });

  final List<Task> tasks;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

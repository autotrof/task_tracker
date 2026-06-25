import '../../data/task.dart';

enum TaskStatusFilter {
  pending(TaskStatus.pending, 'Menunggu'),
  done(TaskStatus.done, 'Selesai');

  const TaskStatusFilter(this.status, this.label);

  final TaskStatus status;
  final String label;
}

enum TaskSortOption {
  newestFirst(
    sortBy: 'created_at',
    sortDirection: 'desc',
    label: 'Terbaru',
    description: 'Tugas terbaru muncul paling atas',
  ),
  oldestFirst(
    sortBy: 'created_at',
    sortDirection: 'asc',
    label: 'Terlama',
    description: 'Tugas paling lama ditampilkan dulu',
  ),
  titleAZ(
    sortBy: 'title',
    sortDirection: 'asc',
    label: 'Judul A-Z',
    description: 'Urut alfabet dari A ke Z',
  ),
  titleZA(
    sortBy: 'title',
    sortDirection: 'desc',
    label: 'Judul Z-A',
    description: 'Urut alfabet dari Z ke A',
  );

  const TaskSortOption({
    required this.sortBy,
    required this.sortDirection,
    required this.label,
    required this.description,
  });

  final String sortBy;
  final String sortDirection;
  final String label;
  final String description;
}

class TaskListState {
  const TaskListState({
    required this.tasks,
    required this.currentPage,
    required this.hasMore,
    required this.statusFilter,
    required this.searchQuery,
    required this.sortOption,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  final List<Task> tasks;
  final int currentPage;
  final bool hasMore;
  final TaskStatusFilter statusFilter;
  final String searchQuery;
  final TaskSortOption sortOption;
  final bool isLoadingMore;
  final bool isRefreshing;

  TaskListState copyWith({
    List<Task>? tasks,
    int? currentPage,
    bool? hasMore,
    TaskStatusFilter? statusFilter,
    String? searchQuery,
    TaskSortOption? sortOption,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

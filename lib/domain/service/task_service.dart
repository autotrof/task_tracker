import '../../data/api_exception.dart';
import '../../data/paginated_tasks.dart';
import '../../data/repository/task_repository.dart';
import '../../data/task.dart';

class TaskService {
  const TaskService(this._repository);

  final TaskRepository _repository;

  Future<PaginatedTasks> loadTasks({
    int page = 1,
    int perPage = 20,
    String? search,
    TaskStatus? status,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  }) {
    return _repository.fetchTasks(
      page: page,
      perPage: perPage,
      search: search?.trim(),
      status: status,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  Future<Task> loadTask(int id) => _repository.fetchTask(id);

  Future<Task> createTask({
    required String title,
    required String description,
  }) {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();

    if (trimmedTitle.isEmpty || trimmedDescription.isEmpty) {
      throw const ApiException('Title and description are required');
    }

    return _repository.createTask(
      title: trimmedTitle,
      description: trimmedDescription,
    );
  }

  Future<Task> toggleStatus(Task task) {
    return _repository.updateStatus(id: task.id, status: task.status.toggled);
  }
}

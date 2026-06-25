import '../paginated_tasks.dart';
import '../task.dart';

abstract class TaskRepository {
  Future<PaginatedTasks> fetchTasks({
    int page = 1,
    int perPage = 20,
    String? search,
    TaskStatus? status,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  });

  Future<Task> fetchTask(int id);

  Future<Task> createTask({required String title, required String description});

  Future<Task> updateStatus({required int id, required TaskStatus status});
}

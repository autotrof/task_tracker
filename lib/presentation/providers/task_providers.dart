import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_env.dart';
import '../../data/paginated_tasks.dart';
import '../../data/repository/dio_task_repository.dart';
import '../../data/repository/task_repository.dart';
import '../../data/task.dart';
import '../../domain/service/task_service.dart';
import 'task_list_state.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );
});

final sharedPreferencesProvider = Provider<Future<SharedPreferences>>((ref) {
  return SharedPreferences.getInstance();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return DioTaskRepository(
    dio: ref.watch(dioProvider),
    preferences: ref.watch(sharedPreferencesProvider),
  );
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(taskRepositoryProvider));
});

final taskListProvider = AsyncNotifierProvider<TaskListNotifier, TaskListState>(
  TaskListNotifier.new,
);

class TaskListNotifier extends AsyncNotifier<TaskListState> {
  static const _perPage = 20;
  TaskStatusFilter _statusFilter = TaskStatusFilter.pending;
  String _searchQuery = '';
  TaskSortOption _sortOption = TaskSortOption.newestFirst;

  @override
  Future<TaskListState> build() async {
    return _loadPage(page: 1);
  }

  Future<void> refresh() async {
    final previousState = _currentState;
    if (previousState != null) {
      state = AsyncData(previousState.copyWith(isRefreshing: true));
    } else {
      state = const AsyncLoading();
    }

    try {
      state = AsyncData(await _loadPage(page: 1));
    } catch (error, stackTrace) {
      if (previousState != null) {
        state = AsyncData(previousState);
        Error.throwWithStackTrace(error, stackTrace);
      }
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> setStatusFilter(TaskStatusFilter filter) async {
    if (_statusFilter == filter) {
      return;
    }

    _statusFilter = filter;
    await refresh();
  }

  Future<void> setSearchQuery(String query) async {
    final normalizedQuery = query.trim();
    if (_searchQuery == normalizedQuery) {
      return;
    }

    _searchQuery = normalizedQuery;
    await refresh();
  }

  Future<void> setSortOption(TaskSortOption sortOption) async {
    if (_sortOption == sortOption) {
      return;
    }

    _sortOption = sortOption;
    await refresh();
  }

  Future<void> loadMore() async {
    final currentState = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = await _fetchPage(currentState.currentPage + 1);
      state = AsyncData(
        TaskListState(
          tasks: [...currentState.tasks, ...nextPage.tasks],
          currentPage: nextPage.currentPage,
          hasMore: nextPage.hasMore,
          statusFilter: currentState.statusFilter,
          searchQuery: currentState.searchQuery,
          sortOption: currentState.sortOption,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncData(currentState);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
  }) async {
    final previousState = _currentState;
    if (previousState != null) {
      state = AsyncData(previousState.copyWith(isRefreshing: true));
    } else {
      state = const AsyncLoading();
    }

    try {
      await ref
          .read(taskServiceProvider)
          .createTask(title: title, description: description);
      state = AsyncData(await _loadPage(page: 1));
    } catch (error, stackTrace) {
      if (previousState != null) {
        state = AsyncData(previousState);
      } else {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    final previousState = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (previousState != null) {
      state = AsyncData(
        previousState.copyWith(
          tasks: [
            for (final item in previousState.tasks)
              item.id == task.id
                  ? item.copyWith(status: item.status.toggled)
                  : item,
          ],
        ),
      );
    }

    try {
      final updatedTask = await ref
          .read(taskServiceProvider)
          .toggleStatus(task);
      final currentState = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (currentState == null) {
        state = AsyncData(await _loadPage(page: 1));
        return;
      }

      state = AsyncData(
        currentState.copyWith(
          tasks: switch (currentState.statusFilter.status) {
            final status when updatedTask.status != status => [
              for (final item in currentState.tasks)
                if (item.id != updatedTask.id) item,
            ],
            _ => [
              for (final item in currentState.tasks)
                if (item.id == updatedTask.id) updatedTask else item,
            ],
          },
        ),
      );
    } catch (error, stackTrace) {
      if (previousState != null) {
        state = AsyncData(previousState);
      }
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<TaskListState> _loadPage({required int page}) async {
    final result = await _fetchPage(page);
    return TaskListState(
      tasks: result.tasks,
      currentPage: result.currentPage,
      hasMore: result.hasMore,
      statusFilter: _statusFilter,
      searchQuery: _searchQuery,
      sortOption: _sortOption,
    );
  }

  Future<PaginatedTasks> _fetchPage(int page) {
    return ref
        .read(taskServiceProvider)
        .loadTasks(
          page: page,
          perPage: _perPage,
          search: _searchQuery,
          status: _statusFilter.status,
          sortBy: _sortOption.sortBy,
          sortDirection: _sortOption.sortDirection,
        );
  }

  TaskListState? get _currentState => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };
}

final taskDetailProvider = FutureProvider.family<Task, int>((ref, id) {
  return ref.watch(taskServiceProvider).loadTask(id);
});

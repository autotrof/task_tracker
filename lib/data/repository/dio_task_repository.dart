import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_exception.dart';
import '../paginated_tasks.dart';
import '../task.dart';
import 'task_repository.dart';

class DioTaskRepository implements TaskRepository {
  DioTaskRepository({required this.dio, required this.preferences});

  static const _cacheKey = 'cached_tasks';

  final Dio dio;
  final Future<SharedPreferences> preferences;

  @override
  Future<PaginatedTasks> fetchTasks({
    int page = 1,
    int perPage = 20,
    String? search,
    TaskStatus? status,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  }) async {
    final normalizedSearch = search?.trim();
    final cacheKey = _cacheKeyFor(
      search: normalizedSearch,
      status: status,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );

    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/tasks',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (normalizedSearch != null && normalizedSearch.isNotEmpty)
            'search': normalizedSearch,
          if (status != null) 'status': status.apiValue,
          'sort_by': sortBy,
          'sort_direction': sortDirection,
        },
      );
      final paginatedTasks = _parsePaginatedTasks(response.data);
      if (page == 1) {
        await _cacheTasks(cacheKey, paginatedTasks.tasks);
      }
      return paginatedTasks;
    } on DioException catch (error) {
      final cachedTasks = await _readCachedTasks(cacheKey);
      if (cachedTasks.isNotEmpty && page == 1) {
        return PaginatedTasks(
          tasks: cachedTasks,
          currentPage: 1,
          lastPage: 1,
        );
      }
      throw _toApiException(error);
    }
  }

  @override
  Future<Task> fetchTask(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/tasks/$id');
      return _parseTaskObject(response.data);
    } on DioException catch (error) {
      final cachedTask = (await _readCachedTasks(_cacheKey))
          .where((task) => task.id == id)
          .firstOrNull;
      if (cachedTask != null) {
        return cachedTask;
      }
      throw _toApiException(error);
    }
  }

  @override
  Future<Task> createTask({
    required String title,
    required String description,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/tasks',
        data: {'title': title, 'description': description},
      );
      return _parseTaskObject(response.data);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  @override
  Future<Task> updateStatus({
    required int id,
    required TaskStatus status,
  }) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '/tasks/$id',
        data: {'status': status.apiValue},
      );
      return _parseTaskObject(response.data);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  PaginatedTasks _parsePaginatedTasks(Map<String, dynamic>? json) {
    final data = json?['data'];
    final meta = json?['meta'];
    if (data is! List) {
      throw const FormatException('Invalid task list response');
    }
    if (meta is! Map<String, dynamic>) {
      throw const FormatException('Invalid task pagination response');
    }

    final currentPage = meta['current_page'];
    final lastPage = meta['last_page'];
    if (currentPage is! int || lastPage is! int) {
      throw const FormatException('Invalid pagination metadata');
    }

    return PaginatedTasks(
      tasks: data
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  Task _parseTaskObject(Map<String, dynamic>? json) {
    final data = json?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid task response');
    }
    return Task.fromJson(data);
  }

  String _cacheKeyFor({
    String? search,
    TaskStatus? status,
    required String sortBy,
    required String sortDirection,
  }) {
    final hasSearch = search != null && search.isNotEmpty;
    final isDefaultSort =
        sortBy == 'created_at' && sortDirection == 'desc';
    if (!hasSearch && status == null && isDefaultSort) {
      return _cacheKey;
    }

    return '$_cacheKey::${status?.apiValue ?? 'all'}::${search ?? ''}::$sortBy::$sortDirection';
  }

  Future<void> _cacheTasks(String cacheKey, List<Task> tasks) async {
    final prefs = await preferences;
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(cacheKey, encoded);
  }

  Future<List<Task>> _readCachedTasks(String cacheKey) async {
    final prefs = await preferences;
    final cachedValue = prefs.getString(cacheKey);
    if (cachedValue == null) {
      return const [];
    }

    final decoded = jsonDecode(cachedValue);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  ApiException _toApiException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final fieldErrors = <String, List<String>>{};
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List) {
            fieldErrors[entry.key] = value.map((item) => '$item').toList();
          }
        }
      }

      return ApiException(
        data['message'] as String? ?? 'Request failed',
        fieldErrors: fieldErrors,
      );
    }

    return ApiException(
      error.message ?? 'Could not connect to the task server',
    );
  }
}

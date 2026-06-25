import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_providers.dart';
import '../providers/task_list_state.dart';
import '../widgets/empty_tasks.dart';
import '../widgets/error_state.dart';
import '../widgets/task_card.dart';
import 'add_task_page.dart';
import 'task_detail_page.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskList = ref.watch(taskListProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6D3), Color(0xFFF8F6F1)],
          ),
        ),
        child: SafeArea(
          child: taskList.when(
            loading: () => ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                _PageHeader(searchBar: _buildSearchBar()),
                const SizedBox(height: 32),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (error, stackTrace) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                _PageHeader(searchBar: _buildSearchBar()),
                const SizedBox(height: 18),
                ErrorState(
                  message: '$error',
                  onRetry: () =>
                      ref.read(taskListProvider.notifier).refresh(),
                ),
              ],
            ),
            data: (taskState) {
              return RefreshIndicator(
                onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                  itemCount: _itemCount(taskState) + 1,
                  separatorBuilder: (_, index) =>
                      index == 0 ? const SizedBox(height: 18) : const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _PageHeader(
                        searchBar: _buildSearchBar(),
                        bottomContent: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatusTabs(
                              activeFilter: taskState.statusFilter,
                              onChanged: (filter) {
                                ref
                                    .read(taskListProvider.notifier)
                                    .setStatusFilter(filter);
                              },
                            ),
                            const SizedBox(height: 14),
                            _SortButton(
                              selectedOption: taskState.sortOption,
                              onSelected: (option) {
                                ref
                                    .read(taskListProvider.notifier)
                                    .setSortOption(option);
                              },
                            ),
                            if (taskState.isRefreshing) ...[
                              const SizedBox(height: 10),
                              const LinearProgressIndicator(
                                minHeight: 2,
                                backgroundColor: Color(0xFFE7E5E4),
                              ),
                            ] else ...[
                              const SizedBox(height: 6),
                            ],
                          ],
                        ),
                      );
                    }

                    final taskIndex = index - 1;
                    if (taskState.tasks.isEmpty) {
                      return EmptyTasks(
                        title:
                            'Tidak ada task ${taskState.statusFilter.label.toLowerCase()}',
                        description: taskState.searchQuery.isEmpty
                            ? 'Daftar ini masih kosong. Tambahkan task baru atau pindahkan status dari halaman detail.'
                            : 'Belum ada hasil untuk pencarian "${taskState.searchQuery}". Coba kata kunci lain.',
                        icon: taskState.searchQuery.isEmpty
                            ? Icons.inbox_rounded
                            : Icons.search_off_rounded,
                      );
                    }

                    if (taskIndex >= taskState.tasks.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final task = taskState.tasks[taskIndex];
                    return TaskCard(
                      task: task,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TaskDetailPage(taskId: task.id),
                          ),
                        );
                      },
                      onToggleStatus: () async {
                        try {
                          await ref
                              .read(taskListProvider.notifier)
                              .toggleTaskStatus(task);
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('$error')));
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AddTaskPage()));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari judul task',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                  ref.read(taskListProvider.notifier).setSearchQuery('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
      onChanged: (value) {
        setState(() {});
        _searchDebounce?.cancel();
        _searchDebounce = Timer(const Duration(milliseconds: 350), () {
          ref.read(taskListProvider.notifier).setSearchQuery(value);
        });
      },
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) {
      return;
    }

    ref.read(taskListProvider.notifier).loadMore().catchError((_) {});
  }

  int _itemCount(TaskListState state) {
    final bodyCount = state.tasks.isEmpty ? 1 : state.tasks.length;
    return bodyCount + (state.isLoadingMore ? 1 : 0);
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.searchBar,
    this.bottomContent,
  });

  final Widget searchBar;
  final Widget? bottomContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Task Tracker',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        searchBar,
        if (bottomContent != null) ...[
          const SizedBox(height: 14),
          bottomContent!,
        ],
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.activeFilter, required this.onChanged});

  final TaskStatusFilter activeFilter;
  final ValueChanged<TaskStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
      child: Row(
        children: [
          for (final filter in TaskStatusFilter.values)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: filter == TaskStatusFilter.pending ? 0 : 6,
                ),
                child: _StatusTabButton(
                  label: filter.label,
                  isActive: filter == activeFilter,
                  onTap: () => onChanged(filter),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusTabButton extends StatelessWidget {
  const _StatusTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFF5E6D3) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isActive ? const Color(0xFF111827) : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.selectedOption,
    required this.onSelected,
  });

  final TaskSortOption selectedOption;
  final ValueChanged<TaskSortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskSortOption>(
      tooltip: 'Sorting',
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in TaskSortOption.values)
          PopupMenuItem<TaskSortOption>(
            value: option,
            child: Row(
              children: [
                Expanded(child: Text(option.label)),
                if (option == selectedOption)
                  const Icon(Icons.check_rounded, size: 18),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E5E4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_vert_rounded,
              size: 18,
              color: Color(0xFF1746A2),
            ),
            const SizedBox(width: 8),
            Text(
              'Sort: ${selectedOption.label}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

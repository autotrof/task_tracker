import 'package:flutter/material.dart';

import '../../data/task.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final isDone = status == TaskStatus.done;
    final backgroundColor = isDone
        ? const Color(0xFFDDF7E7)
        : const Color(0xFFFFE8BF);
    final foregroundColor = isDone
        ? const Color(0xFF047857)
        : const Color(0xFF9A5B00);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

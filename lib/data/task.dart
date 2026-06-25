enum TaskStatus {
  pending,
  done;

  static TaskStatus fromJson(String value) {
    return switch (value) {
      'done' => TaskStatus.done,
      'pending' => TaskStatus.pending,
      _ => throw FormatException('Status tugas tidak dikenal: $value'),
    };
  }

  String get apiValue => switch (this) {
    TaskStatus.pending => 'pending',
    TaskStatus.done => 'done',
  };

  String get label => switch (this) {
    TaskStatus.pending => 'Pending',
    TaskStatus.done => 'Selesai',
  };

  TaskStatus get toggled => switch (this) {
    TaskStatus.pending => TaskStatus.done,
    TaskStatus.done => TaskStatus.pending,
  };
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.apiValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

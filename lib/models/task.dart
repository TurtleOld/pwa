class Task {
  final int id;
  final String? slug;
  final String name;
  final String description;
  final bool state;
  final DateTime? deadline;
  final DateTime createdAt;
  final int? stage;
  final int? executor;
  final int author;
  final List<int> labels;
  final List<int> reminderPeriods;
  final int order;

  Task({
    required this.id,
    this.slug,
    required this.name,
    required this.description,
    required this.state,
    this.deadline,
    required this.createdAt,
    this.stage,
    this.executor,
    required this.author,
    required this.labels,
    required this.reminderPeriods,
    required this.order,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      slug: json['slug'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      state: json['state'] as bool? ?? false,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      stage: json['stage'] as int?,
      executor: json['executor'] as int?,
      author: json['author'] as int,
      labels: (json['labels'] as List<dynamic>?)?.cast<int>() ?? [],
      reminderPeriods:
          (json['reminder_periods'] as List<dynamic>?)?.cast<int>() ?? [],
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'state': state,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'stage': stage,
      'executor': executor,
      'author': author,
      'labels': labels,
      'reminder_periods': reminderPeriods,
      'order': order,
    };
  }

  Task copyWith({
    int? id,
    String? slug,
    String? name,
    String? description,
    bool? state,
    DateTime? deadline,
    DateTime? createdAt,
    int? stage,
    int? executor,
    int? author,
    List<int>? labels,
    List<int>? reminderPeriods,
    int? order,
  }) {
    return Task(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      state: state ?? this.state,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      stage: stage ?? this.stage,
      executor: executor ?? this.executor,
      author: author ?? this.author,
      labels: labels ?? this.labels,
      reminderPeriods: reminderPeriods ?? this.reminderPeriods,
      order: order ?? this.order,
    );
  }

  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  String get deadlineFormatted {
    if (deadline == null) return '';
    final now = DateTime.now();
    final difference = deadline!.difference(now);

    if (difference.isNegative) {
      return 'Просрочено';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} дн.';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч.';
    } else {
      return '${difference.inMinutes} мин.';
    }
  }
}

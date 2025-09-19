class Stage {
  final int id;
  final String name;
  final int order;

  Stage({
    required this.id,
    required this.name,
    required this.order,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'] as int,
      name: json['name'] as String,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
    };
  }

  String get displayName {
    switch (name) {
      case 'to_do':
        return 'Запланировано';
      case 'in_progress':
        return 'В процессе';
      case 'review':
        return 'На проверке';
      case 'done':
        return 'Выполнено';
      default:
        return name;
    }
  }

  String get icon {
    switch (name) {
      case 'to_do':
        return '📋';
      case 'in_progress':
        return '⚡';
      case 'review':
        return '👀';
      case 'done':
        return '✅';
      default:
        return '📄';
    }
  }
}

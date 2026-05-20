import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({
    String? id,
    required this.title,
    this.completed = false,
  }) : id = id ?? const Uuid().v4();

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          completed == other.completed;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ completed.hashCode;
}

part of 'todo_bloc.dart';

abstract class TodoState {
  const TodoState();
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  const TodoLoaded(this.todos);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoLoaded &&
          runtimeType == other.runtimeType &&
          todos == other.todos;

  @override
  int get hashCode => todos.hashCode;
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);
}

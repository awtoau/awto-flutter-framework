import 'package:awto_cli_demo/models/todo.dart';

abstract class TodoState {
  const TodoState();
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  const TodoLoaded(this.todos);
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);
}

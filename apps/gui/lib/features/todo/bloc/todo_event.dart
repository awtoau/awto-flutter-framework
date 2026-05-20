part of 'todo_bloc.dart';

abstract class TodoEvent {
  const TodoEvent();
}

class AddTodo extends TodoEvent {
  final String title;
  const AddTodo(this.title);
}

class RemoveTodo extends TodoEvent {
  final String id;
  const RemoveTodo(this.id);
}

class ToggleTodo extends TodoEvent {
  final String id;
  const ToggleTodo(this.id);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final List<Todo> _todos = [];

  TodoBloc() : super(const TodoInitial()) {
    on<AddTodo>(_onAddTodo);
    on<RemoveTodo>(_onRemoveTodo);
    on<ToggleTodo>(_onToggleTodo);
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      _todos.add(Todo(title: event.title));
      emit(TodoLoaded(List.unmodifiable(_todos)));
    } catch (e) {
      emit(TodoError('Failed to add todo: $e'));
    }
  }

  Future<void> _onRemoveTodo(RemoveTodo event, Emitter<TodoState> emit) async {
    try {
      _todos.removeWhere((todo) => todo.id == event.id);
      emit(TodoLoaded(List.unmodifiable(_todos)));
    } catch (e) {
      emit(TodoError('Failed to remove todo: $e'));
    }
  }

  Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == event.id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(completed: !_todos[index].completed);
        emit(TodoLoaded(List.unmodifiable(_todos)));
      }
    } catch (e) {
      emit(TodoError('Failed to toggle todo: $e'));
    }
  }
}

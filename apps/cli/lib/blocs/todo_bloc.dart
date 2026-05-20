import 'package:bloc/bloc.dart';
import 'package:awto_cli_demo/models/todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final List<Todo> _todos = [];
  int _nextId = 1;

  TodoBloc() : super(const TodoInitial()) {
    on<AddTodo>(_onAddTodo);
    on<RemoveTodo>(_onRemoveTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<ListTodos>(_onListTodos);
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      final todo = Todo(
        id: _nextId.toString(),
        title: event.title,
      );
      _nextId++;
      _todos.add(todo);
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

  Future<void> _onListTodos(ListTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoaded(List.unmodifiable(_todos)));
  }
}

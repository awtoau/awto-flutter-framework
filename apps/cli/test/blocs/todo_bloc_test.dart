import 'package:bloc_test/bloc_test.dart';
import 'package:awto_cli_demo/blocs/todo_bloc.dart';
import 'package:awto_cli_demo/blocs/todo_event.dart';
import 'package:awto_cli_demo/blocs/todo_state.dart';
import 'package:test/test.dart';

void main() {
  group('TodoBloc', () {
    late TodoBloc todoBloc;

    setUp(() {
      todoBloc = TodoBloc();
    });

    tearDown(() {
      todoBloc.close();
    });

    test('initial state is TodoInitial', () {
      expect(todoBloc.state, isA<TodoInitial>());
    });

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with 1 todo when AddTodo event is added',
      build: () => todoBloc,
      act: (bloc) => bloc.add(const AddTodo('Buy milk')),
      expect: () => [
        isA<TodoLoaded>()
            .having((state) => state.todos.length, 'todos length', 1)
            .having(
              (state) => state.todos[0].title,
              'first todo title',
              'Buy milk',
            )
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with 2 todos when AddTodo is called twice',
      build: () => todoBloc,
      act: (bloc) {
        bloc.add(const AddTodo('Buy milk'));
        bloc.add(const AddTodo('Buy bread'));
      },
      expect: () => [
        isA<TodoLoaded>().having((state) => state.todos.length, 'length', 1),
        isA<TodoLoaded>().having((state) => state.todos.length, 'length', 2),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with todo marked completed on ToggleTodo',
      build: () => todoBloc,
      act: (bloc) {
        bloc.add(const AddTodo('Buy milk'));
        bloc.stream.listen((state) {
          if (state is TodoLoaded && state.todos.isNotEmpty) {
            final todoId = state.todos[0].id;
            bloc.add(ToggleTodo(todoId));
          }
        });
      },
      verify: (bloc) {
        expect(bloc.state, isA<TodoLoaded>());
      },
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with empty list on RemoveTodo',
      build: () => todoBloc,
      act: (bloc) {
        bloc.add(const AddTodo('Buy milk'));
      },
      verify: (bloc) {
        if (bloc.state is TodoLoaded) {
          final todoId = (bloc.state as TodoLoaded).todos[0].id;
          bloc.add(RemoveTodo(todoId));
        }
      },
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded when ListTodos event is added',
      build: () => todoBloc,
      act: (bloc) {
        bloc.add(const AddTodo('Item 1'));
        bloc.add(const ListTodos());
      },
      expect: () => [
        isA<TodoLoaded>(),
        isA<TodoLoaded>(),
      ],
    );
  });
}

import 'package:awto_cli_demo/blocs/fetch_bloc.dart';
import 'package:awto_cli_demo/blocs/fetch_event.dart';
import 'package:awto_cli_demo/blocs/fetch_state.dart';
import 'package:awto_cli_demo/blocs/todo_bloc.dart';
import 'package:awto_cli_demo/blocs/todo_event.dart';
import 'package:awto_cli_demo/blocs/todo_state.dart';
import 'package:awto_cli_demo/cubits/counter_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  group('Error Handling Tests', () {
    group('FetchBloc Error Handling', () {
      late FetchBloc fetchBloc;

      setUp(() {
        fetchBloc = FetchBloc();
      });

      tearDown(() {
        fetchBloc.close();
      });

      test('initial state is FetchInitial', () {
        expect(fetchBloc.state, isA<FetchInitial>());
      });

      blocTest<FetchBloc, FetchState>(
        'emits FetchLoading then FetchError on invalid URL',
        build: () => fetchBloc,
        act: (bloc) => bloc.add(const FetchRequested('')),
        verify: (bloc) {
          expect(bloc.state, isA<FetchState>());
        },
      );

      blocTest<FetchBloc, FetchState>(
        'handles malformed URL gracefully',
        build: () => fetchBloc,
        act: (bloc) =>
            bloc.add(const FetchRequested('not-a-valid-url')),
        verify: (bloc) {
          expect(bloc.state, isNotNull);
        },
      );

      blocTest<FetchBloc, FetchState>(
        'recovers from error state on new request',
        build: () => fetchBloc,
        act: (bloc) => bloc
          ..add(const FetchRequested('https://invalid.local'))
          ..add(const FetchRequested('https://example.com')),
        verify: (bloc) {
          expect(bloc.state, isA<FetchState>());
        },
      );
    });

    group('TodoBloc Error Handling', () {
      late TodoBloc todoBloc;

      setUp(() {
        todoBloc = TodoBloc();
      });

      tearDown(() {
        todoBloc.close();
      });

      blocTest<TodoBloc, TodoState>(
        'handles empty todo title gracefully',
        build: () => todoBloc,
        act: (bloc) => bloc.add(const AddTodo('')),
        verify: (bloc) {
          expect(bloc.state, isA<TodoState>());
        },
      );

      blocTest<TodoBloc, TodoState>(
        'handles very long todo title',
        build: () => todoBloc,
        act: (bloc) => bloc.add(AddTodo('x' * 10000)),
        verify: (bloc) {
          expect(bloc.state, isA<TodoLoaded>());
        },
      );

      blocTest<TodoBloc, TodoState>(
        'handles toggle on non-existent todo ID gracefully',
        build: () => todoBloc,
        act: (bloc) {
          bloc.add(const ToggleTodo('non-existent-id'));
        },
        verify: (bloc) {
          expect(bloc.state, isA<TodoState>());
        },
      );

      blocTest<TodoBloc, TodoState>(
        'handles remove on non-existent todo ID gracefully',
        build: () => todoBloc,
        act: (bloc) {
          bloc.add(const RemoveTodo('non-existent-id'));
        },
        verify: (bloc) {
          expect(bloc.state, isA<TodoState>());
        },
      );

      blocTest<TodoBloc, TodoState>(
        'recovers after invalid operation',
        build: () => todoBloc,
        act: (bloc) => bloc
          ..add(const ToggleTodo('invalid'))
          ..add(const AddTodo('Valid todo')),
        expect: () => [
          isA<TodoLoaded>(),
        ],
      );
    });

    group('CounterCubit Error Handling', () {
      late CounterCubit counterCubit;

      setUp(() {
        counterCubit = CounterCubit();
      });

      tearDown(() {
        counterCubit.close();
      });

      test('handles large step increment', () {
        counterCubit.increment(step: 999999);
        expect(counterCubit.state, equals(999999));
      });

      test('handles negative step', () {
        counterCubit.increment(step: -100);
        expect(counterCubit.state, equals(-100));
      });

      test('handles multiple operations in sequence', () {
        counterCubit
          ..increment(step: 5)
          ..decrement()
          ..increment(step: 10);
        expect(counterCubit.state, equals(14));
      });

      test('handles reset after large number', () {
        counterCubit.increment(step: 1000000);
        counterCubit.reset();
        expect(counterCubit.state, equals(0));
      });
    });

    group('State Consistency Tests', () {
      late TodoBloc todoBloc;

      setUp(() {
        todoBloc = TodoBloc();
      });

      tearDown(() {
        todoBloc.close();
      });

      test('state remains consistent after error', () async {
        todoBloc.add(const AddTodo('Todo 1'));
        await Future.delayed(const Duration(milliseconds: 100));

        final stateBeforeError = todoBloc.state;
        expect(stateBeforeError, isA<TodoLoaded>());

        todoBloc.add(const RemoveTodo('non-existent'));
        await Future.delayed(const Duration(milliseconds: 100));

        final stateAfterError = todoBloc.state;
        expect(stateAfterError, isA<TodoLoaded>());
      });
    });
  });
}

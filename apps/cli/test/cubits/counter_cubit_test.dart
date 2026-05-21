import 'package:bloc_test/bloc_test.dart';
import 'package:awto_cli_demo/cubits/counter_cubit.dart';
import 'package:test/test.dart';

void main() {
  group('CounterCubit', () {
    late CounterCubit counterCubit;

    setUp(() {
      counterCubit = CounterCubit();
    });

    tearDown(() {
      counterCubit.close();
    });

    test('initial state is 0', () {
      expect(counterCubit.state, equals(0));
    });

    blocTest<CounterCubit, int>(
      'emits [1] when increment is called',
      build: () => counterCubit,
      act: (cubit) => cubit.increment(),
      expect: () => [1],
    );

    blocTest<CounterCubit, int>(
      'emits [5] when increment(step: 5) is called',
      build: () => counterCubit,
      act: (cubit) => cubit.increment(step: 5),
      expect: () => [5],
    );

    blocTest<CounterCubit, int>(
      'emits [-1] when decrement is called from 0',
      build: () => counterCubit,
      act: (cubit) => cubit.decrement(),
      expect: () => [-1],
    );

    blocTest<CounterCubit, int>(
      'emits [2, 1] when incremented then decremented',
      build: () => counterCubit,
      act: (cubit) {
        cubit.increment(step: 2);
        cubit.decrement();
      },
      expect: () => [2, 1],
    );

    blocTest<CounterCubit, int>(
      'emits [5, 0] when incremented(step: 5) then reset',
      build: () => counterCubit,
      act: (cubit) {
        cubit.increment(step: 5);
        cubit.reset();
      },
      expect: () => [5, 0],
    );
  });
}

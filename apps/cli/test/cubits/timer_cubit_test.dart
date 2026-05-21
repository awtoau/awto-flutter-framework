import 'package:bloc_test/bloc_test.dart';
import 'package:awto_cli_demo/cubits/timer_cubit.dart';
import 'package:test/test.dart';

void main() {
  group('TimerCubit', () {
    late TimerCubit timerCubit;

    setUp(() {
      timerCubit = TimerCubit();
    });

    tearDown(() {
      timerCubit.close();
    });

    test('initial state is correct', () {
      expect(timerCubit.state.elapsedMs, equals(0));
      expect(timerCubit.state.isRunning, equals(false));
      expect(timerCubit.state.laps, isEmpty);
    });

    test('formatted getter returns 00:00.00 for zero state', () {
      expect(timerCubit.state.formatted, equals('00:00.00'));
    });

    blocTest<TimerCubit, TimerState>(
      'recordLap appends to laps list',
      build: () => timerCubit,
      act: (cubit) {
        cubit.recordLap();
      },
      verify: (cubit) {
        expect(cubit.state.laps.length, equals(1));
        expect(cubit.state.laps[0], equals(0));
      },
    );

    blocTest<TimerCubit, TimerState>(
      'reset returns to initial state',
      build: () {
        timerCubit.recordLap();
        timerCubit.recordLap();
        return timerCubit;
      },
      act: (cubit) => cubit.reset(),
      verify: (cubit) {
        expect(cubit.state.elapsedMs, equals(0));
        expect(cubit.state.isRunning, equals(false));
        expect(cubit.state.laps, isEmpty);
      },
    );

    blocTest<TimerCubit, TimerState>(
      'stop sets isRunning to false',
      build: () => timerCubit,
      act: (cubit) {
        cubit.start();
        cubit.stop();
      },
      verify: (cubit) {
        expect(cubit.state.isRunning, equals(false));
      },
    );
  });
}

import 'dart:io';
import 'package:args/args.dart';
import 'package:awto_cli_demo/cubits/timer_cubit.dart';

void runTimerCommand(ArgResults results) {
  final enableLaps = results['lap'] as bool;
  final cubit = TimerCubit();

  print('=== Timer Demo (Cubit) ===');
  print('');
  print('Commands:');
  print('  start    - Start the timer');
  print('  stop     - Stop the timer');
  print('  reset    - Reset to 00:00.00');
  if (enableLaps) {
    print('  lap      - Record a lap');
  }
  print('  quit     - Exit');
  print('');

  cubit.stream.listen((state) {
    stdout.write('\rTime: ${state.formatted}');
    if (state.laps.isNotEmpty && enableLaps) {
      stdout.write(' | Laps: ${state.laps.length}');
    }
    stdout.write('  ');
    stdout.writeCharCodes([8]); // Move cursor back
  });

  while (true) {
    stdout.write('\n> ');
    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

    if (input.isEmpty) continue;

    switch (input) {
      case 'start':
        cubit.start();
      case 'stop':
        cubit.stop();
      case 'reset':
        cubit.reset();
        print('Reset!');
      case 'lap':
        if (enableLaps) {
          cubit.recordLap();
          final state = cubit.state;
          print('Lap ${state.laps.length}: ${state.formatted}');
        } else {
          print('Lap recording disabled. Use --lap flag.');
        }
      case 'q':
      case 'quit':
        cubit.stop();
        print('\nGoodbye!');
        return;
      default:
        print('Unknown command: $input');
    }
  }
}

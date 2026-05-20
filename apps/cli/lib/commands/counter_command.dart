import 'dart:io';
import 'package:args/args.dart';
import 'package:awto_cli_demo/cubits/counter_cubit.dart';

void runCounterCommand(ArgResults results) {
  final step = int.tryParse(results['step'] as String) ?? 1;
  final cubit = CounterCubit();

  print('=== Counter Demo (Cubit) ===');
  print('Current: ${cubit.state}');
  print('');
  print('Commands: +, -, r (reset), q (quit)');
  print('Example: + 5 (increment by 5)');
  print('');

  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

    if (input.isEmpty) continue;

    final parts = input.split(' ');
    final command = parts[0];
    final arg = parts.length > 1 ? int.tryParse(parts[1]) : null;

    switch (command) {
      case '+':
      case 'inc':
      case 'increment':
        final customStep = arg ?? step;
        cubit.increment(step: customStep);
        print('Current: ${cubit.state}');
      case '-':
      case 'dec':
      case 'decrement':
        final customStep = arg ?? step;
        cubit.decrement(step: customStep);
        print('Current: ${cubit.state}');
      case 'r':
      case 'reset':
        cubit.reset();
        print('Reset! Current: ${cubit.state}');
      case 'q':
      case 'quit':
        print('Goodbye!');
        return;
      default:
        print('Unknown command: $command');
    }
  }
}

import 'package:args/args.dart';
import 'package:awto_cli_demo/commands/counter_command.dart';
import 'package:awto_cli_demo/commands/todo_command.dart';
import 'package:awto_cli_demo/commands/fetch_command.dart';
import 'package:awto_cli_demo/commands/timer_command.dart';
import 'package:awto_cli_demo/commands/ports_command.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('counter', _counterParser())
    ..addCommand('todo', _todoParser())
    ..addCommand('fetch', _fetchParser())
    ..addCommand('timer', _timerParser())
    ..addCommand('ports', _portsParser())
    ..addFlag('help', negatable: false, help: 'Show help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool || results.command == null) {
      _printHelp();
      return;
    }

    switch (results.command!.name) {
      case 'counter':
        runCounterCommand(results.command!);
      case 'todo':
        runTodoCommand(results.command!);
      case 'fetch':
        runFetchCommand(results.command!);
      case 'timer':
        runTimerCommand(results.command!);
      case 'ports':
        runPortsCommand(results.command!);
      default:
        _printHelp();
    }
  } catch (e) {
    print('Error: $e');
  }
}

ArgParser _counterParser() => ArgParser()
  ..addOption('step', defaultsTo: '1', help: 'Increment step size');

ArgParser _todoParser() => ArgParser();

ArgParser _fetchParser() => ArgParser()
  ..addOption('url', defaultsTo: 'https://jsonplaceholder.typicode.com/posts/1',
      help: 'URL to fetch');

ArgParser _timerParser() => ArgParser()
  ..addFlag('lap', negatable: false, help: 'Enable lap recording');

ArgParser _portsParser() => ArgParser();

void _printHelp() {
  print('''
awto-flutter-framework CLI Demo

Usage: dart run bin/main.dart <command> [options]

Commands:
  counter [--step N]     Cubit demo: increment/decrement counter
  todo                   Bloc demo: interactive task list
  fetch [--url URL]      Bloc async demo: HTTP fetch with states
  timer [--lap]          Cubit demo: stopwatch timer
  ports                  Scan and display USB/serial port map

Options:
  --help                 Show this help message

Examples:
  dart run bin/main.dart counter
  dart run bin/main.dart counter --step 5
  dart run bin/main.dart fetch --url https://example.com/api/data
  dart run bin/main.dart timer --lap
  dart run bin/main.dart ports
''');
}

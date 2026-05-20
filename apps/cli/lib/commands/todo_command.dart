import 'dart:io';
import 'package:args/args.dart';
import 'package:awto_cli_demo/blocs/todo_bloc.dart';
import 'package:awto_cli_demo/blocs/todo_event.dart';
import 'package:awto_cli_demo/blocs/todo_state.dart';

void runTodoCommand(ArgResults results) {
  final bloc = TodoBloc();

  print('=== Todo Demo (Bloc) ===');
  print('');
  print('Commands:');
  print('  add <title>    - Add a new todo');
  print('  rm <id>        - Remove todo by id');
  print('  toggle <id>    - Toggle todo completion');
  print('  list           - List all todos');
  print('  quit           - Exit');
  print('');

  bloc.stream.listen((state) {
    if (state is TodoLoaded) {
      print('Todos (${state.todos.length}):');
      if (state.todos.isEmpty) {
        print('  (empty)');
      } else {
        for (final todo in state.todos) {
          print('  ${todo}');
        }
      }
    } else if (state is TodoError) {
      print('Error: ${state.message}');
    }
  });

  // Initial list
  bloc.add(const ListTodos());

  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync()?.trim() ?? '';

    if (input.isEmpty) continue;

    final parts = input.split(' ');
    final command = parts[0].toLowerCase();

    switch (command) {
      case 'add':
        if (parts.length < 2) {
          print('Usage: add <title>');
        } else {
          final title = parts.skip(1).join(' ');
          bloc.add(AddTodo(title));
        }
      case 'rm':
      case 'remove':
        if (parts.length < 2) {
          print('Usage: rm <id>');
        } else {
          bloc.add(RemoveTodo(parts[1]));
        }
      case 'toggle':
        if (parts.length < 2) {
          print('Usage: toggle <id>');
        } else {
          bloc.add(ToggleTodo(parts[1]));
        }
      case 'list':
        bloc.add(const ListTodos());
      case 'quit':
      case 'q':
        print('Goodbye!');
        return;
      default:
        print('Unknown command: $command');
    }
  }
}

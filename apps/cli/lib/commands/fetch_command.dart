import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:awto_cli_demo/blocs/fetch_bloc.dart';
import 'package:awto_cli_demo/blocs/fetch_event.dart';
import 'package:awto_cli_demo/blocs/fetch_state.dart';

void runFetchCommand(ArgResults results) {
  final url = results['url'] as String;
  final bloc = FetchBloc();

  print('=== Fetch Demo (Bloc) ===');
  print('URL: $url');
  print('');

  bloc.stream.listen((state) {
    if (state is FetchLoading) {
      print('[Loading...]');
    } else if (state is FetchSuccess) {
      print('[Success] Status: ${state.statusCode}');
      print('Response:');
      final encoded = jsonEncode(state.data);
      print(jsonDecode(encoded));
    } else if (state is FetchFailure) {
      print('[Error] ${state.error}');
    }
  });

  // Trigger initial fetch
  bloc.add(FetchRequested(url));

  print('Commands: retry, q (quit)');
  print('');

  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

    if (input.isEmpty) continue;

    switch (input) {
      case 'retry':
        bloc.add(FetchRetried(url));
      case 'q':
      case 'quit':
        print('Goodbye!');
        return;
      default:
        print('Unknown command: $input');
    }
  }
}

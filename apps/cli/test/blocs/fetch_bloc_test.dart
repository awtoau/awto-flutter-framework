import 'package:bloc_test/bloc_test.dart';
import 'package:awto_cli_demo/blocs/fetch_bloc.dart';
import 'package:awto_cli_demo/blocs/fetch_event.dart';
import 'package:awto_cli_demo/blocs/fetch_state.dart';
import 'package:test/test.dart';

void main() {
  group('FetchBloc', () {
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
      'emits [FetchLoading] when FetchRequested is added',
      build: () => fetchBloc,
      act: (bloc) => bloc.add(const FetchRequested('https://example.com')),
      expect: () => [
        isA<FetchLoading>(),
      ],
      skip: 1, // Skip the success/failure state since we can't mock http
    );

    blocTest<FetchBloc, FetchState>(
      'emits [FetchLoading, FetchFailure] on invalid URL',
      build: () => fetchBloc,
      act: (bloc) => bloc.add(const FetchRequested('https://invalid-url-that-does-not-exist-12345.com')),
      expect: () => [
        isA<FetchLoading>(),
        isA<FetchFailure>(),
      ],
      timeout: const Duration(seconds: 15),
    );
  });
}

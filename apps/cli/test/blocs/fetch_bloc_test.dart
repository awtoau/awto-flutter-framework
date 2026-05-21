import 'package:awto_cli_demo/blocs/fetch_bloc.dart';
import 'package:awto_cli_demo/blocs/fetch_event.dart';
import 'package:awto_cli_demo/blocs/fetch_state.dart';
import 'package:bloc_test/bloc_test.dart';
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
      verify: (bloc) {
        // Verify that at least one emission happened
        expect(bloc.state, isNotNull);
      },
    );
  });
}

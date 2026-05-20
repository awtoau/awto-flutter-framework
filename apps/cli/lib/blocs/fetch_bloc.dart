import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'fetch_event.dart';
import 'fetch_state.dart';

class FetchBloc extends Bloc<FetchEvent, FetchState> {
  FetchBloc() : super(const FetchInitial()) {
    on<FetchRequested>(_onFetchRequested);
    on<FetchRetried>(_onFetchRetried);
  }

  Future<void> _onFetchRequested(
    FetchRequested event,
    Emitter<FetchState> emit,
  ) async {
    emit(const FetchLoading());
    await _performFetch(event.url, emit);
  }

  Future<void> _onFetchRetried(
    FetchRetried event,
    Emitter<FetchState> emit,
  ) async {
    emit(const FetchLoading());
    await _performFetch(event.url, emit);
  }

  Future<void> _performFetch(String url, Emitter<FetchState> emit) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        emit(FetchSuccess(data, response.statusCode));
      } else {
        emit(FetchFailure('HTTP ${response.statusCode}: ${response.reasonPhrase}'));
      }
    } on TimeoutException catch (e) {
      emit(FetchFailure(e.message));
    } catch (e) {
      emit(FetchFailure('Error: $e'));
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

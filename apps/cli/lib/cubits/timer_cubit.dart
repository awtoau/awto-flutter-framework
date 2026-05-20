import 'dart:async';
import 'package:bloc/bloc.dart';

class TimerState {
  final int elapsedMs;
  final List<int> laps;
  final bool isRunning;

  TimerState({
    required this.elapsedMs,
    required this.laps,
    required this.isRunning,
  });

  TimerState copyWith({
    int? elapsedMs,
    List<int>? laps,
    bool? isRunning,
  }) {
    return TimerState(
      elapsedMs: elapsedMs ?? this.elapsedMs,
      laps: laps ?? this.laps,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  String get formatted {
    final mins = (elapsedMs ~/ 60000).toString().padLeft(2, '0');
    final secs = ((elapsedMs ~/ 1000) % 60).toString().padLeft(2, '0');
    final ms = ((elapsedMs % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$mins:$secs.$ms';
  }
}

class TimerCubit extends Cubit<TimerState> {
  Timer? _timer;

  TimerCubit()
      : super(TimerState(
          elapsedMs: 0,
          laps: [],
          isRunning: false,
        ));

  void start() {
    if (state.isRunning) return;

    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      emit(state.copyWith(elapsedMs: state.elapsedMs + 10));
    });

    emit(state.copyWith(isRunning: true));
  }

  void stop() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void reset() {
    _timer?.cancel();
    emit(TimerState(
      elapsedMs: 0,
      laps: [],
      isRunning: false,
    ));
  }

  void recordLap() {
    final newLaps = [...state.laps, state.elapsedMs];
    emit(state.copyWith(laps: newLaps));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

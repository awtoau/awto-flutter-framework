import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment({int step = 1}) => emit(state + step);
  void decrement({int step = 1}) => emit(state - step);
  void reset() => emit(0);
}

part of 'fetch_bloc.dart';

abstract class FetchState {
  const FetchState();
}

class FetchInitial extends FetchState {
  const FetchInitial();
}

class FetchLoading extends FetchState {
  const FetchLoading();
}

class FetchSuccess extends FetchState {
  final Map<String, dynamic> data;
  final int statusCode;

  const FetchSuccess(this.data, this.statusCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchSuccess &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          statusCode == other.statusCode;

  @override
  int get hashCode => data.hashCode ^ statusCode.hashCode;
}

class FetchFailure extends FetchState {
  final String error;

  const FetchFailure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchFailure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

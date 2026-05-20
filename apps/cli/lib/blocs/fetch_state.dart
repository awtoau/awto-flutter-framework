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
}

class FetchFailure extends FetchState {
  final String error;

  const FetchFailure(this.error);
}

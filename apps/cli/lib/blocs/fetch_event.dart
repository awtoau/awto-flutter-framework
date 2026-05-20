abstract class FetchEvent {
  const FetchEvent();
}

class FetchRequested extends FetchEvent {
  final String url;

  const FetchRequested(this.url);
}

class FetchRetried extends FetchEvent {
  final String url;

  const FetchRetried(this.url);
}

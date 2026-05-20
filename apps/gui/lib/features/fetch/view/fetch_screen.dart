import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/fetch_bloc.dart';

class FetchScreen extends StatelessWidget {
  const FetchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FetchBloc(),
      child: const _FetchView(),
    );
  }
}

class _FetchView extends StatefulWidget {
  const _FetchView({Key? key}) : super(key: key);

  @override
  State<_FetchView> createState() => _FetchViewState();
}

class _FetchViewState extends State<_FetchView> {
  static const String _defaultUrl = 'https://jsonplaceholder.typicode.com/posts/1';
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _defaultUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetch Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('URL:',  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'Enter URL...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton.extended(
                      heroTag: 'fetch',
                      onPressed: () {
                        context.read<FetchBloc>().add(
                          FetchRequested(_urlController.text),
                        );
                      },
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Fetch'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<FetchBloc, FetchState>(
              builder: (context, state) {
                if (state is FetchInitial) {
                  return const Center(
                    child: Text('Enter a URL and tap Fetch'),
                  );
                }

                if (state is FetchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is FetchSuccess) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${state.statusCode}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Response:',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: SelectableText(
                                    _formatJson(state.data),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: FloatingActionButton.extended(
                            heroTag: 'retry',
                            onPressed: () {
                              context.read<FetchBloc>().add(
                                FetchRetried(_urlController.text),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is FetchFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        FloatingActionButton.extended(
                          heroTag: 'retry_error',
                          onPressed: () {
                            context.read<FetchBloc>().add(
                              FetchRetried(_urlController.text),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}

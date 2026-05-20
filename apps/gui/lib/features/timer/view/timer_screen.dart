import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/timer_cubit.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerCubit(),
      child: const _TimerView(),
    );
  }
}

class _TimerView extends StatelessWidget {
  const _TimerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: BlocBuilder<TimerCubit, TimerState>(
                builder: (context, state) {
                  return Text(
                    state.formatted,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 96,
                          fontFamily: 'monospace',
                        ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<TimerCubit, TimerState>(
                  builder: (context, state) {
                    return FloatingActionButton.extended(
                      heroTag: 'start_stop',
                      onPressed: () {
                        if (state.isRunning) {
                          context.read<TimerCubit>().stop();
                        } else {
                          context.read<TimerCubit>().start();
                        }
                      },
                      icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(state.isRunning ? 'Stop' : 'Start'),
                    );
                  },
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'lap',
                  onPressed: () {
                    context.read<TimerCubit>().recordLap();
                  },
                  icon: const Icon(Icons.bookmark),
                  label: const Text('Lap'),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'reset',
                  onPressed: () {
                    context.read<TimerCubit>().reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: BlocBuilder<TimerCubit, TimerState>(
              builder: (context, state) {
                if (state.laps.isEmpty) {
                  return const Center(
                    child: Text('No laps recorded'),
                  );
                }

                return ListView.builder(
                  itemCount: state.laps.length,
                  itemBuilder: (context, index) {
                    final lapTime = state.laps[index];
                    final mins = (lapTime ~/ 60000).toString().padLeft(2, '0');
                    final secs = ((lapTime ~/ 1000) % 60).toString().padLeft(2, '0');
                    final ms = ((lapTime % 1000) ~/ 10).toString().padLeft(2, '0');
                    final formatted = '$mins:$secs.$ms';

                    return ListTile(
                      title: Text('Lap ${index + 1}'),
                      trailing: Text(
                        formatted,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/counter_cubit.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const _CounterView(),
    );
  }
}

class _CounterView extends StatelessWidget {
  const _CounterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Count:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CounterCubit, int>(
              builder: (context, count) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'decrement',
                  onPressed: () {
                    context.read<CounterCubit>().decrement();
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'reset',
                  onPressed: () {
                    context.read<CounterCubit>().reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'increment',
                  onPressed: () {
                    context.read<CounterCubit>().increment();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

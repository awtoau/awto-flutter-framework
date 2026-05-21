import 'dart:async';

import 'package:test/test.dart';

void main() {
  group('Memory Leak Detection', () {
    test(
      'intentional memory leak - large allocation without cleanup',
      skip: 'Skipped by default - allocates 100MB and locks machines.\n'
          'Run manually for profiling: dart --observe test/memory_leak_test.dart',
      () {
      // This test intentionally leaks memory to verify leak detection works
      // Run with: dart --enable-asserts test test/memory_leak_test.dart
      // Or with profiling: dart --observe test test/memory_leak_test.dart

      final leakedList = [];

      // Allocate ~100MB of memory without releasing
      for (int i = 0; i < 100; i++) {
        leakedList.add(List<int>.filled(1024 * 1024, i));
      }

      // Verify the list exists (prevent dead code elimination)
      expect(leakedList.length, equals(100));

      // Memory is NOT cleaned up - this creates the leak
      // In production code, you would do: leakedList.clear();
      },
    );

    test(
      'memory leak in closure - retained references',
      skip: 'Skipped by default - allocates ~100MB.\n'
          'Run manually for profiling.',
      () {
      // Another common leak pattern: closures retaining references
      final callbacks = [];

      for (int i = 0; i < 1000; i++) {
        final data = List<int>.filled(100 * 1024, i); // 100KB per iteration
        callbacks.add(() => data.length); // Closure captures data
      }

      // data objects are retained by closures and never released
      expect(callbacks.length, equals(1000));
      // Cleanup would be: callbacks.clear();
      },
    );

    test(
      'memory leak in stream subscriptions',
      skip: 'Skipped by default - allocates significant memory.\n'
          'Run manually for profiling.',
      () async {
      // Leak pattern: subscriptions not cancelled
      final stream = Stream.periodic(const Duration(milliseconds: 1), (i) => i)
          .asBroadcastStream();
      final subscriptions = [];

      for (int i = 0; i < 10; i++) {
        subscriptions.add(
          stream.listen((_) {
            // Listener retains resources
          }),
        );
      }

      expect(subscriptions.length, equals(10));
      // Cleanup would be: subscriptions.forEach((s) => s.cancel());
      },
    );
  });
}

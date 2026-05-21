import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awto_gui_demo/features/counter/view/counter_screen.dart';

void main() {
  group('CounterScreen', () {
    testWidgets('Renders counter screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterScreen(),
        ),
      );

      expect(find.byType(CounterScreen), findsOneWidget);
      expect(find.text('Counter Demo'), findsOneWidget);
      expect(find.text('Count:'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Increment button increases counter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterScreen(),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Tap increment button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Reset button returns to 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterScreen(),
        ),
      );

      // Increment twice
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);

      // Tap reset button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
    });
  });
}

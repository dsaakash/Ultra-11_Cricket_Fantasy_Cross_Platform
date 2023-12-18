import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tempalteflutter/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the initial text is '0'.
    expect(find.text('0'), findsOneWidget);

    // Tap on the widget to trigger the increment.
    await tester.tap(find.byIcon(Icons.add));

    // Rebuild the widget after the tap.
    await tester.pump();

    // Verify that the text is now '1' after the increment.
    expect(find.text('1'), findsOneWidget);
  });
}

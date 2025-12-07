// Basic smoke test for the Routine Stopwatch app.
import 'package:flutter_test/flutter_test.dart';
import 'package:routine_stopwatch/main.dart';

void main() {
  testWidgets('App loads with loading screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoutineStopwatchApp());

    // Verify that the app title is displayed
    expect(find.text('Routine Stopwatch'), findsOneWidget);
  });
}

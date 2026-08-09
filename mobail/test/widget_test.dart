import 'package:flutter_test/flutter_test.dart';

import 'package:mobail/main.dart';

void main() {
  testWidgets('Beep Beep app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BeepBeepApp());

    // Verify that app title is displayed
    expect(find.text('Beep Beep Design System'), findsOneWidget);
  });
}

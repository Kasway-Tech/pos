import 'package:atomikpos/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that the app starts.
    expect(find.byType(App), findsOneWidget);
  });
}

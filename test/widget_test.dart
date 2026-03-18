import 'package:kasway/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(App(prefs: prefs));

    // Verify that the app starts.
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}

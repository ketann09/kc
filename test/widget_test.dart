import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('KabadiwalaConnectApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const KabadiwalaConnectApp());
    await tester.pumpAndSettle();

    expect(find.byType(KabadiwalaConnectApp), findsOneWidget);
    expect(find.text('नमस्ते!'), findsOneWidget);
    expect(find.text('लॉग इन करें'), findsWidgets);
  });
}

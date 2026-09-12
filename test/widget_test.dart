import 'package:flutter_test/flutter_test.dart';
import 'package:last_bite/main.dart'; // <--- Usar last_bite

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LastBiteApp());
  });
}
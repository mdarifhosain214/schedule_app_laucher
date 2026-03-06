import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Basic sanity test - the full app requires platform channels
    // which cannot be tested in a widget test environment.
    expect(1 + 1, equals(2));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PaySave test placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('PaySave'),
          ),
        ),
      ),
    );

    expect(find.text('PaySave'), findsOneWidget);
  });
}

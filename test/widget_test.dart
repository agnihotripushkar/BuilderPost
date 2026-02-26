import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('BuilderPost AI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BuilderPostApp()));
    expect(find.text('BuilderPost AI'), findsOneWidget);
  });
}

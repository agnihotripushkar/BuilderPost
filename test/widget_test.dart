import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/widgets/platform_chips.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('PlatformChips renders all three platforms', (tester) async {
    await tester.pumpWidget(
      host(PlatformChips(selected: 'peerlist', onChanged: (_) {})),
    );

    expect(find.text('Peerlist'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('X / Twitter'), findsOneWidget);
  });

  testWidgets('tapping a chip reports the new platform id', (tester) async {
    String? picked;
    await tester.pumpWidget(
      host(PlatformChips(selected: 'peerlist', onChanged: (v) => picked = v)),
    );

    await tester.tap(find.text('LinkedIn'));
    expect(picked, 'linkedin');
  });
}

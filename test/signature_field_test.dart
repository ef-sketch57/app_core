import 'dart:typed_data';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signature/signature.dart';

void main() {
  testWidgets('une signature peut comporter plusieurs traits', (tester) async {
    Uint8List? value;
    var exports = 0;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(AppPalette.quittances),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SignatureField(
            value: value,
            onChanged: (png) => setState(() {
              value = png;
              if (png != null) exports++;
            }),
          ),
        ),
      ),
    ));

    Future<void> stroke(Offset from) async {
      final pad = tester.getTopLeft(find.byType(Signature));
      final gesture = await tester.startGesture(pad + from);
      for (var i = 1; i <= 10; i++) {
        await gesture.moveBy(const Offset(8, 3));
        await tester.pump();
      }
      await gesture.up();
      // L'export PNG passe par le moteur de rendu : hors de l'horloge de test.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
    }

    await stroke(const Offset(20, 30));
    expect(exports, 1);
    // Le second trait doit encore être possible : la zone de dessin reste active.
    expect(find.byType(Signature), findsOneWidget);
    await stroke(const Offset(40, 70));
    expect(exports, 2);
    expect(value, isNotNull);
  });
}

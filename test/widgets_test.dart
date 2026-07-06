import 'package:coacher/data/models/measurement.dart';
import 'package:coacher/data/models/role.dart';
import 'package:coacher/widgets/app_toggle.dart';
import 'package:coacher/widgets/coacher_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Role parse matcht database-enum', () {
    expect(Role.tryParse('coach'), Role.coach);
    expect(Role.tryParse('klant'), Role.klant);
    expect(Role.tryParse('admin'), isNull);
    expect(Role.coach.db, 'coach');
  });

  test('17 meetwaardes met exacte measure_keys', () {
    expect(measures.length, 17);
    expect(measures.first.key, 'gewicht');
    expect(
      measures.map((m) => m.key),
      containsAll(['bmi', 'vetpercentage', 'taille', 'rechterkuit']),
    );
  });

  test('4 fotocategorieën', () {
    expect(photoCategories.map((c) => c.$1),
        ['voor', 'zij', 'achter', 'extra']);
  });

  testWidgets('CoacherButton toont "Bezig…" tijdens laden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoacherButton(
            loading: true,
            onPressed: () {},
            child: const Text('Inloggen'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Bezig…'), findsOneWidget);
    expect(find.text('Inloggen'), findsNothing);
  });

  testWidgets('AppToggle schakelt bij tik', (tester) async {
    var value = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AppToggle(
              on: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(AppToggle));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });
}

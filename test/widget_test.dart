// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_my_day/feature/ddayFeature/domain/entities/dday_entity.dart';
import 'package:make_my_day/feature/scheduleFeature/domain/entities/schedule_entity.dart';
import 'package:make_my_day/infrastructure/manager/realm_schema_version_manager.dart';

import 'package:make_my_day/main.dart';
import 'package:realm/realm.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final config = RealmSchemaVersionManager.getConfig();
    final realm = Realm(config);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(realm: realm));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

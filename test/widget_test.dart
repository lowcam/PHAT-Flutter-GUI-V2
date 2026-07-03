import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phat_flutter_gui/main.dart';
import 'package:phat_flutter_gui/constants.dart';

void main() {
  void _setLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
  }

  testWidgets('Initial UI state test', (WidgetTester tester) async {
    _setLargeViewport(tester);
    await tester.pumpWidget(const PhatApp());
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appTitle), findsWidgets);
    expect(find.text('Output will appear here'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('CALCULATE'), findsOneWidget);
  });

  testWidgets('Clear All button resets the UI', (WidgetTester tester) async {
    _setLargeViewport(tester);
    await tester.pumpWidget(const PhatApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'secret');
    await tester.enterText(find.byType(TextFormField).at(1), 'mysalt');
    await tester.pumpAndSettle();
    
    final clearAllButton = find.text('Clear All');
    await tester.tap(clearAllButton);
    await tester.pumpAndSettle();

    expect(find.text('secret'), findsNothing);
    expect(find.text('mysalt'), findsNothing);
    expect(find.text('Output will appear here'), findsOneWidget);
  });

  testWidgets('Algorithm selection updates UI', (WidgetTester tester) async {
    _setLargeViewport(tester);
    await tester.pumpWidget(const PhatApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SHA-256'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Argon2id').last);
    await tester.pumpAndSettle();

    expect(find.text('Enter site name or unique ID...'), findsOneWidget);
    expect(find.text('ADVANCED KDF SETTINGS'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/platform/swipe_back.dart';

Widget _app(GlobalKey<NavigatorState> nav) => MaterialApp(
      navigatorKey: nav,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.iOS: FullSwipeBackPageTransitionsBuilder()},
        ),
      ),
      home: const Scaffold(body: Center(child: Text('root'))),
    );

Future<void> _pushDetail(WidgetTester tester, GlobalKey<NavigatorState> nav, {Widget? body}) async {
  unawaited(nav.currentState!.push(MaterialPageRoute<void>(
    builder: (_) => Scaffold(
      body: body ?? ListView(children: [for (var i = 0; i < 40; i++) ListTile(title: Text('row $i'))]),
    ),
  )));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a rightward drag from the middle of the page goes back', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_app(nav));
    await _pushDetail(tester, nav);
    expect(find.text('row 0'), findsOneWidget);

    await tester.flingFrom(const Offset(200, 300), const Offset(260, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('root'), findsOneWidget);
    expect(find.text('row 0'), findsNothing);
  });

  testWidgets('a short slow drag springs back and keeps the page', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_app(nav));
    await _pushDetail(tester, nav);

    final gesture = await tester.startGesture(const Offset(200, 300));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(6, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('row 0'), findsOneWidget);
  });

  testWidgets('a leftward drag and a vertical scroll never go back', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_app(nav));
    await _pushDetail(tester, nav);

    await tester.dragFrom(const Offset(300, 300), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('row 0'), findsOneWidget);

    await tester.dragFrom(const Offset(200, 400), const Offset(30, -250));
    await tester.pumpAndSettle();
    expect(find.text('root'), findsNothing);
  });

  testWidgets('a horizontal page view keeps its swipe; the edge still goes back', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    final pages = PageController(initialPage: 1);
    await tester.pumpWidget(_app(nav));
    await _pushDetail(
      tester,
      nav,
      body: PageView(controller: pages, children: [for (var i = 0; i < 3; i++) Center(child: Text('page $i'))]),
    );

    await tester.flingFrom(const Offset(200, 300), const Offset(300, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('page 0'), findsOneWidget);

    await tester.flingFrom(const Offset(4, 300), const Offset(300, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('root'), findsOneWidget);
  });
}

// This is a basic Flutter widget test for the MVVM architecture demo.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/main.dart';
import 'package:gyaanplant/viewmodels/home_viewmodel.dart';

void main() {
  testWidgets('App loads and displays HomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Verify that HomeScreen is displayed
    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.text('GyaanPlant'), findsOneWidget);
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Verify that our counter starts at 0.
    expect(find.text('Counter: 0'), findsOneWidget);

    // Tap the floating action button '+' icon and trigger a frame.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('Counter: 0'), findsNothing);
    expect(find.text('Counter: 1'), findsOneWidget);
  });

  testWidgets('Navigation to SecondScreen works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Find and tap the navigation button
    final navigateButton = find.text('Navigate to Second Screen');
    expect(navigateButton, findsOneWidget);

    await tester.tap(navigateButton);
    await tester.pumpAndSettle();

    // Verify that SecondScreen is displayed
    expect(find.text('Second Screen'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'This is the second screen of the MVVM architecture demo. It demonstrates how navigation works with go_router and how to create clean, reusable UI components.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ViewModel state management works correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Get the HomeViewModel instance
    final homeViewModel = Provider.of<HomeViewModel>(
      tester.element(find.byType(Scaffold)),
      listen: false,
    );

    // Verify initial state
    expect(homeViewModel.counter, 0);
    expect(homeViewModel.isLoading, false);
    expect(homeViewModel.errorMessage, '');

    // Test increment
    homeViewModel.incrementCounter();
    await tester.pump();

    expect(find.text('Counter: 1'), findsOneWidget);
  });
}

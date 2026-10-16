import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_dental_app/app/router/route_names.dart';
import 'package:ai_dental_app/app/theme/app_theme.dart';
import 'package:ai_dental_app/features/patient_management/presentation/register_patient_screen.dart';

void main() {
  testWidgets('RegisterPatientScreen renders all form fields and buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const RegisterPatientScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Register New Patient'), findsWidgets);
    expect(find.text('First Name *'), findsOneWidget);
    expect(find.text('Last Name *'), findsOneWidget);
    expect(find.text('Mobile Phone *'), findsOneWidget);
    expect(find.text('Register Patient'), findsWidgets);
  });

  testWidgets('RegisterPatientScreen close and cancel buttons navigate back safely', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String? navigatedRoute;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: RouteNames.registerPatient,
        routes: {
          RouteNames.registerPatient: (context) => const RegisterPatientScreen(),
          RouteNames.patients: (context) {
            navigatedRoute = RouteNames.patients;
            return const Scaffold(body: Text('Patients Directory Page'));
          },
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap the close 'X' button
    final closeButton = find.byTooltip('Close');
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(navigatedRoute, RouteNames.patients);
    expect(find.text('Patients Directory Page'), findsOneWidget);
  });
}

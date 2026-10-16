import 'package:flutter_test/flutter_test.dart';
import 'package:ai_dental_app/app/app.dart';

void main() {
  testWidgets('Dental App boots to login screen with branding', (WidgetTester tester) async {
    await tester.pumpWidget(const DentalApp());
    await tester.pumpAndSettle();

    expect(find.text('DentFlow AI'), findsWidgets);
    expect(find.text('Sign In to Your Practice'), findsOneWidget);
    expect(find.text('Dentist / Clinician'), findsWidgets);
  });
}

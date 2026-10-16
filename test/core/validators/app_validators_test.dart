import 'package:ai_dental_app/core/validators/app_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppValidators Unit Tests', () {
    test('email validator validates standard email formats', () {
      expect(AppValidators.email(null), isNotNull);
      expect(AppValidators.email(''), isNotNull);
      expect(AppValidators.email('invalid-email'), isNotNull);
      expect(AppValidators.email('doctor@clinic'), isNotNull);
      expect(AppValidators.email('doctor@clinic.com'), isNull);
      expect(AppValidators.email('staff.member+test@dental-care.org'), isNull);
    });

    test('password validator validates strength requirements', () {
      expect(AppValidators.password(null), isNotNull);
      expect(AppValidators.password('short'), isNotNull);
      expect(AppValidators.password('alllowercase1!'), isNotNull); // No uppercase
      expect(AppValidators.password('ALLUPPERCASE1!'), isNotNull); // No lowercase
      expect(AppValidators.password('NoDigitsSpecial!'), isNotNull); // No digit
      expect(AppValidators.password('NoSpecial1234'), isNotNull); // No symbol
      expect(AppValidators.password('Password123!'), isNull); // Valid
    });

    test('confirmPassword matches passwords', () {
      expect(AppValidators.confirmPassword('Password123!', 'Password123!'), isNull);
      expect(AppValidators.confirmPassword('Mismatch123!', 'Password123!'), isNotNull);
    });

    test('phone validator accepts valid international and local formats', () {
      expect(AppValidators.phone(null), isNotNull);
      expect(AppValidators.phone('123'), isNotNull);
      expect(AppValidators.phone('+91 98765 43210'), isNull);
      expect(AppValidators.phone('+14155552671'), isNull);
    });

    test('otp validator checks 6 digit code', () {
      expect(AppValidators.otp(null), isNotNull);
      expect(AppValidators.otp('12345'), isNotNull);
      expect(AppValidators.otp('1234567'), isNotNull);
      expect(AppValidators.otp('abcdef'), isNotNull);
      expect(AppValidators.otp('123456'), isNull);
    });

    test('clinicName validator requires minimum 2 chars', () {
      expect(AppValidators.clinicName(null), isNotNull);
      expect(AppValidators.clinicName('A'), isNotNull);
      expect(AppValidators.clinicName('Apex Dental Care'), isNull);
    });

    test('postalCode validator validates length', () {
      expect(AppValidators.postalCode(null), isNotNull);
      expect(AppValidators.postalCode('12'), isNotNull);
      expect(AppValidators.postalCode('560001'), isNull);
    });
  });
}

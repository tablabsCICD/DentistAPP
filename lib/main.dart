import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize App Configuration
  AppConfig.initialize(
    const AppConfig(
      appName: 'DentFlow AI',
      apiBaseUrl: 'https://api.dentflow.ai/v1',
      useMockData: true,
      isProduction: false,
    ),
  );

  runApp(const DentalApp());
}

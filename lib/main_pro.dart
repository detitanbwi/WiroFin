import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'main.dart'; // import WiroExpenseApp

import 'core/services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceService.instance.init();
  
  AppConfig.instance = ProConfig();
  setupInjection();
  runApp(const WiroFinApp());
}

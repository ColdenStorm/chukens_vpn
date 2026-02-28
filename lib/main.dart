import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_device_apps_android/flutter_device_apps_android.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.load();
  if (defaultTargetPlatform == TargetPlatform.android) {
    FlutterDeviceAppsAndroid.registerWith();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(nextPage: LoginScreen()),
    );
  }
}

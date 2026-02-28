import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _keyAutoConnect = 'autoConnectOnAppStart';
  static const _keyReconnectOnDrop = 'reconnectOnDrop';
  static const _keyKillSwitchSystemWide = 'killSwitchSystemWide';
  static const _keyKillSwitchAppLevel = 'killSwitchAppLevel';

  static bool autoConnectOnAppStart = true;
  static bool reconnectOnDrop = true;
  static bool killSwitchSystemWide = false;
  static bool killSwitchAppLevel = false;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    autoConnectOnAppStart = prefs.getBool(_keyAutoConnect) ?? autoConnectOnAppStart;
    reconnectOnDrop = prefs.getBool(_keyReconnectOnDrop) ?? reconnectOnDrop;
    killSwitchSystemWide = prefs.getBool(_keyKillSwitchSystemWide) ?? killSwitchSystemWide;
    killSwitchAppLevel = prefs.getBool(_keyKillSwitchAppLevel) ?? killSwitchAppLevel;
  }

  static Future<void> setAutoConnectOnAppStart(bool value) async {
    autoConnectOnAppStart = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoConnect, value);
  }

  static Future<void> setReconnectOnDrop(bool value) async {
    reconnectOnDrop = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReconnectOnDrop, value);
  }

  static Future<void> setKillSwitchSystemWide(bool value) async {
    killSwitchSystemWide = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKillSwitchSystemWide, value);
  }

  static Future<void> setKillSwitchAppLevel(bool value) async {
    killSwitchAppLevel = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKillSwitchAppLevel, value);
  }
}


import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  static const String _pushKey = 'push_notifications';
  static const String _emailKey = 'email_alerts';
  static const String _smsKey = 'sms_alerts';

  static Future<bool> getPushNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushKey) ?? true;
  }

  static Future<void> setPushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
  }

  static Future<bool> getEmailAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_emailKey) ?? true;
  }

  static Future<void> setEmailAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailKey, value);
  }

  static Future<bool> getSmsAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_smsKey) ?? false;
  }

  static Future<void> setSmsAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smsKey, value);
  }
}

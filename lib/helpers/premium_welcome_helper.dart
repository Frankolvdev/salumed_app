import 'package:shared_preferences/shared_preferences.dart';

/// Show the Premium invitation only after an explicit successful authentication.
Future<void> queuePremiumWelcome() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('salumed_premium_welcome_pending', true);
}

Future<bool> consumePremiumWelcome() async {
  final prefs = await SharedPreferences.getInstance();
  final pending = prefs.getBool('salumed_premium_welcome_pending') ?? false;
  if (pending) await prefs.remove('salumed_premium_welcome_pending');
  return pending;
}

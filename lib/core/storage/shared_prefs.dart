import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;
Future<SharedPreferences> getPrefs() async {
  return prefs = await SharedPreferences.getInstance();
}

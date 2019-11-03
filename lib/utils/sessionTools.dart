//tools for session cookie management
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

//save session cookie to memory
saveSessionCookie(sessionCookie) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('sessionCookie', sessionCookie);
}

//only get all characters up to semicolon
cleanCookie(cookie) {
  RegExp upToSemiColon = new RegExp(r".*(?=\;)");
  String str = cookie;
  //to use in all future API requests
  globals.cleanedCookie = upToSemiColon.stringMatch(str).toString();
}

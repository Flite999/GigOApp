import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';
import '../utils/globals.dart' as globals;
import '../utils/sessionTools.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/initTools.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  //init vars for user input
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  //for modal overlay while loading session cookie
  bool isLoading = false;
  final baseUrl = dotenv.env['GIG_O_URL'];

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  void _loginFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: new Text('Login Failed'),
            content: new Text('Please check email and password and try again.'),
            actions: <Widget>[
              new TextButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]);
      },
    );
  }

  launchSignUp() async {
    final Uri url = Uri.parse("${baseUrl}/member/signup");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchForgotPass() async {
    final Uri url = Uri.parse("${baseUrl}/member/member-password-reset/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchSupportEmail() async {
    final Uri url =
        Uri.parse("mailto:gigoapp24@gmail.com?subject=App%20Question");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future authenticate(String email, String pass) async {
    // var url = Uri.parse("${baseUrl}/accounts/login/");
    // try {
    //   await http.post(url, headers: {
    //     "X-CSRFToken": globals.csrfToken,
    //     'Cookie': 'csrftoken=${globals.csrfToken}'
    //   }, body: {
    //     "email": "$email",
    //     "password": "$pass"
    //   }).then((response) {
    //     int authenticateReturnCode = response.statusCode;
    //     if (authenticateReturnCode == 200) {
    //       print('Login successful');
    //       cleanCookie(response.headers["set-cookie"]);
    //       print('response cookie: ${response.headers["set-cookie"]}');
    //       saveSessionCookie(globals.cleanedCookie);
    //       goToHomePage();
    //     } else {
    //       print('Login failed. Please check username and password');
    //       print('response: ${response.body}');
    //       _loginFailedDialog();
    //     }
    //   });
    // } catch (e) {
    //   print('Authentication error: $e');
    // }
    globals.apiKey = "2aCa3b3tpOEpvGKRvRtpNuXPboc7w2Vzl_fetetd";
    goToHomePage();
  }

  goToHomePage() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  //to-do: if there is an active login session, login screen flashes briefly before moving to home page-would like to fix that
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? new Scaffold(
            backgroundColor: Colors.white,
            body: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text("Checking for Active Session",
                    style: TextStyle(color: Colors.black, fontSize: 25.0)),
                Divider(color: Colors.white),
                new CircularProgressIndicator(
                  strokeWidth: 3.0,
                  value: null,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          )
        : new Scaffold(
            appBar: new AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: new Text('Gig-❤️-Matic',
                    style: new TextStyle(color: Colors.white, fontSize: 35.0)),
              ),
              backgroundColor: const Color.fromARGB(255, 40, 167, 69),
            ),
            body: new Container(
                padding: EdgeInsets.all(16.0),
                decoration: new BoxDecoration(
                  image: DecorationImage(
                      image: new AssetImage('images/tuba.jpg'),
                      fit: BoxFit.contain,
                      repeat: ImageRepeat.repeat),
                  shape: BoxShape.circle,
                ),
                child: new Form(
                  key: formKey,
                  child: ListView(
                    children:
                        buildInputs() + buildSubmitButtons() + buildFooter(),
                  ),
                )),
          );
  }

  List<Widget> buildInputs() {
    return [
      const SizedBox(height: 20.0),
      new TextFormField(
        decoration: new InputDecoration(
            labelText: 'Email ',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Email can\'t be empty';
          }
          if (value.contains(" ")) {
            return 'Please remove spaces from email address';
          }
          return null;
        },
        controller: emailController,
      ),
      const SizedBox(height: 5.0),
      new TextFormField(
        decoration: new InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white),
        obscureText: true,
        validator: (value) =>
            value!.isEmpty ? 'Password can\'t be empty' : null,
        controller: passwordController,
      ),
      const SizedBox(height: 5.0),
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      new ElevatedButton(
          child: new Text('Login',
              style: new TextStyle(fontSize: 25.0, color: Colors.white)),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15.0))),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              authenticate(emailController.text, passwordController.text);
            }
          }),
      new TextButton(
        child: new Text('Create an Account',
            style: new TextStyle(fontSize: 25.0, color: Colors.black)),
        onPressed: launchSignUp,
      ),
      new TextButton(
        child: new Text('Forgot Password?',
            style: new TextStyle(fontSize: 25.0, color: Colors.black)),
        onPressed: launchForgotPass,
      ),
    ];
  }

  List<Widget> buildFooter() {
    return [
      new Align(
          alignment: Alignment.bottomCenter,
          child: new Container(
              padding: EdgeInsets.all(20.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: new AutoSizeText(
                      "Have an issue? Contact support:",
                      style: new TextStyle(fontSize: 25.0),
                      maxLines: 1,
                    ),
                  ),
                  new TextButton.icon(
                    label: new Text(""),
                    icon: new Icon(Icons.email),
                    onPressed: launchSupportEmail,
                  ),
                ],
              )))
    ];
  }
}

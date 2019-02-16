import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'app_home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

//only get all characters up to semicolon
cleanCookie(cookie) {
  RegExp upToSemiColon = new RegExp(r".*(?=\;)");
  String str = cookie;
  //to use in all future API requests
  globals.cleanedCookie = upToSemiColon.stringMatch(str).toString();
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  int authenticateReturnCode;
  String email;
  String password;
  //var to store cookie for session persistence
  String sessionCookie;

  launchSignUp() async {
    const url = "https://www.gig-o-matic.com/signup?locale=en";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchForgotPass() async {
    const url = "https://www.gig-o-matic.com/forgot?locale=en";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchEmailWebmaster() async {
    const url = "mailto:superuser@gig-o-matic.com?subject=App%20Question";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: new Text('Login Failed'),
            content: new Text('Please check email and password and try again.'),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]);
      },
    );
  }

  void initState() {
    super.initState();
    loadSessionCookie();
  }

  //load saved cookie from memory, if returns 200 on a REST call, move to apphome (checking for valid session cookie)
  loadSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionCookie = (prefs.getString('sessionCookie') ?? 0);
    await http.get('https://www.gig-o-matic.com/api/agenda',
        headers: {"cookie": "$sessionCookie"}).then((response) {
      if (response.statusCode == 200) {
        cleanCookie(response.headers["set-cookie"]);
        saveSessionCookie(globals.cleanedCookie);
        goToHomePage();
      }
    });
  }

  //save session cookie to memory
  saveSessionCookie(sessionCookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('sessionCookie', sessionCookie);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text('Gig-O-Matic',
            style: new TextStyle(color: Colors.white, fontSize: 30.0)),
        backgroundColor: Colors.blue,
      ),
      body: new Container(
          padding: EdgeInsets.all(16.0),
          color: Color.fromRGBO(150, 248, 157, 1.0),
          child: new Form(
            key: formKey,
            child: ListView(
              children: buildInputs() + buildSubmitButtons() + buildFooter(),
            ),
          )),
    );
  }

  Future<List> authenticate(String email, String pass) async {
    var url = "https://www.gig-o-matic.com/api/authenticate";
    try {
      await http.post(url, body: {"email": "$email", "password": "$pass"}).then(
          (response) {
        authenticateReturnCode = response.statusCode;
        if (authenticateReturnCode == 200) {
          cleanCookie(response.headers["set-cookie"]);
          saveSessionCookie(globals.cleanedCookie);
          goToHomePage();
        } else {
          print('Login failed. Please check username and password');
          _showDialog();
        }
      });
    } catch (e) {
      print('Error');
    }
  }

  goToHomePage() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
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
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
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
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        controller: passwordController,
      ),
      const SizedBox(height: 5.0),
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      new RaisedButton(
          child: new Text('Login',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          color: Colors.blue,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15.0)),
          onPressed: () {
            if (formKey.currentState.validate()) {
              authenticate(emailController.text, passwordController.text);
            }
          }),
      new FlatButton(
        child: new Text('Create an Account',
            style: new TextStyle(fontSize: 20.0, color: Colors.black)),
        onPressed: launchSignUp,
      ),
      new FlatButton(
        child: new Text('Forgot Password?',
            style: new TextStyle(fontSize: 20.0, color: Colors.black)),
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
                      "Issues or questions? Contact admins here:",
                      style: new TextStyle(fontSize: 20.0),
                      maxLines: 1,
                    ),
                  ),
                  new FlatButton.icon(
                    label: new Text(""),
                    icon: new Icon(Icons.email),
                    onPressed: launchEmailWebmaster,
                  ),
                ],
              )))
    ];
  }
}

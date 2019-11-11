import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';
import '../utils/globals.dart' as globals;
import '../utils/sessionTools.dart';

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

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  //init vars for user input
  final formKey = new GlobalKey<FormState>();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  //for modal overlay while loading session cookie
  bool isLoading = false;

  void initState() {
    super.initState();
    isLoading = true;
    loadSessionCookie();
  }

  void _loginFailedDialog() {
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

  Future authenticate(String email, String pass) async {
    var url = "https://www.gig-o-matic.com/api/authenticate";
    try {
      await http.post(url, body: {"email": "$email", "password": "$pass"}).then(
          (response) {
        int authenticateReturnCode = response.statusCode;
        if (authenticateReturnCode == 200) {
          cleanCookie(response.headers["set-cookie"]);
          saveSessionCookie(globals.cleanedCookie);
          goToHomePage();
        } else {
          print('Login failed. Please check username and password');
          _loginFailedDialog();
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

  //loadSessionCookie MUST live here for proper user state initialization!
  void loadSessionCookie() async {
    //load cookie from memory
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sessionCookie = (prefs.getString('sessionCookie') ?? 0);

    //check session endpoint for active session with cookie
    await http.post('https://www.gig-o-matic.com/api/session',
        headers: {"cookie": "$sessionCookie"}).then((response) {
      if (response.statusCode == 200) {
        cleanCookie(response.headers["set-cookie"]);
        saveSessionCookie(globals.cleanedCookie);
        goToHomePage();
      }
      //if stored cookie not a valid session, send to login screen
      setState(() {
        isLoading = false;
      });
    });
  }

  //to-do: if there is an active login session, login screen flashes briefly before moving to home page-would like to fix that
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return new Stack(
        children: [
          new Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          new Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );
    }
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
          if (value.isEmpty) {
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

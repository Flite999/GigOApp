//http call functions to gig-o-matic API
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/login.dart';
import 'globals.dart' as globals;
import 'sessionTools.dart';
import 'formatTools.dart';
import 'classes.dart';

//todo: the fetch code is very repeatable/simiar, can consolidate to one function with input params

deserializeJSON(response) {
  Map? decoded = json.decode(response.body.toString());
  return decoded;
}

Future<Map?> fetchAgenda() async {
  Map? agenda;
  var url = Uri.parse('https://www.gig-o-matic.com/api/agenda');
  try {
    final response =
        await http.get(url, headers: {"cookie": "${globals.cleanedCookie}"});
    if (response.statusCode == 200) {
      cleanCookie(response.headers["set-cookie"]);
      saveSessionCookie(globals.cleanedCookie);
      agenda = deserializeJSON(response);
    } else {
      print('API call failed, response: ${response.statusCode}');
    }
  } catch (e) {
    print("fetch Gig Info error: $e");
  }
  return agenda;
}

Future<Map?> fetchBandInfo(bandID) async {
  Map? decoded;
  var url = Uri.parse('https://www.gig-o-matic.com/api/band/$bandID');
  try {
    final response =
        await http.get(url, headers: {"cookie": "${globals.cleanedCookie}"});
    if (response.statusCode == 200) {
      cleanCookie(response.headers["set-cookie"]);
      saveSessionCookie(globals.cleanedCookie);
    } else {
      print('API call failed, response: ${response.statusCode}');
    }
    decoded = json.decode(response.body.toString());
  } catch (e) {
    print("fetch Band Section error: $e");
  }
  return decoded;
}

class LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //async logout function and log out listtile widget both defined here
    //Navigator push method has to be part of the postLogout method to correctly invalidate session cookie
    postLogout() async {
      var url = Uri.parse('https://www.gig-o-matic.com/api/logout');
      try {
        await http.post(url,
            headers: {"cookie": "${globals.cleanedCookie}"}).then((response) {
          if (response.statusCode == 200) {
            //posting to the logout returns a cookie in an odd format, but we don't care about properly cleaning it,
            //because the returned cookie is supposed to be invalid for next use anyways
            cleanCookie(response.headers["set-cookie"]);
            saveSessionCookie(globals.cleanedCookie);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            print('API call failed, response: ${response.statusCode}');
          }
        });
      } catch (e) {}
    }

    return ListTile(
      title: Text('Log Out',
          style: TextStyle(
              color: Color.fromRGBO(14, 39, 96, 1.0), fontSize: 21.0)),
      onTap: () {
        postLogout();
      },
    );
  }
}

//user can add or update a comment for a gig
Future postComment(newComment, planID) async {
  var url = Uri.parse('https://www.gig-o-matic.com/api/plan/$planID/comment');
  try {
    await http.post(url,
        headers: {"cookie": "${globals.cleanedCookie}"},
        body: {"comment": "$newComment"}).then((response) {
      if (response.statusCode == 200) {
        cleanCookie(response.headers["set-cookie"]);
        saveSessionCookie(globals.cleanedCookie);
      } else {
        print('API call failed, response: ${response.statusCode}');
      }
    });
  } catch (e) {
    print(e);
  }
}

//user can update their status for a gig
Future putStatus(newValue, planID) async {
  try {
    var url = Uri.parse(
        'https://www.gig-o-matic.com/api/plan/$planID/value/$newValue');
    await http.put(url, headers: {"cookie": "${globals.cleanedCookie}"}).then(
        (response) {
      if (response.statusCode == 200) {
        cleanCookie(response.headers["set-cookie"]);
        saveSessionCookie(globals.cleanedCookie);
      } else {
        print('API call failed, response: ${response.statusCode}');
      }
    });
  } catch (e) {
    print(e);
  }
}

Future<List?> fetchGigMemberInfo(gigID) async {
  List? info;
  try {
    var url = Uri.parse('https://www.gig-o-matic.com/api/gig/plans/$gigID');
    final response =
        await http.get(url, headers: {"cookie": "${globals.cleanedCookie}"});
    if (response.statusCode == 200) {
      cleanCookie(response.headers["set-cookie"]);
      saveSessionCookie(globals.cleanedCookie);
    } else {
      print('error here');
      print('API call failed, response: ${response.statusCode}');
    }
    //can't use the deserialize function here because the plans endpoint returns a List, not Map
    info = json.decode(response.body.toString());
  } catch (e) {
    print(e);
  }
  return info;
}

Future<Map?> fetchGigDetails(gigID) async {
  Map? json;
  var url = Uri.parse('https://www.gig-o-matic.com/api/gig/${gigID}');
  try {
    final response =
        await http.get(url, headers: {"cookie": "${globals.cleanedCookie}"});
    if (response.statusCode == 200) {
      cleanCookie(response.headers["set-cookie"]);
      saveSessionCookie(globals.cleanedCookie);
      json = deserializeJSON(response);
    } else {
      print('API call failed, response: ${response.statusCode}');
    }
  } catch (e) {
    print(e);
  }
  return json;
}

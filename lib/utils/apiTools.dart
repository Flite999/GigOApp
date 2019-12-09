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
  Map decoded = json.decode(response.body.toString());
  return decoded;
}

Future<Map> fetchAgenda() async {
  Map agenda;
  try {
    final response = await http.get('https://www.gig-o-matic.com/api/agenda',
        headers: {"cookie": "${globals.cleanedCookie}"});
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

Future<Map> fetchBandSections(bandIDs) async {
  Map decoded;
  for (int i = 0; i < bandIDs.length; i++) {
    try {
      final response = await http.get(
          'https://www.gig-o-matic.com/api/band/${bandIDs[i]}',
          headers: {"cookie": "${globals.cleanedCookie}"});
      if (response.statusCode == 200) {
        cleanCookie(response.headers["set-cookie"]);
        saveSessionCookie(globals.cleanedCookie);
      } else {
        print('API call failed, response: ${response.statusCode}');
      }
      decoded = json.decode(response.body.toString());
    } catch (e) {
      print("fetch Band Section New error: $e");
    }
  }
  return decoded;
}

class LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //async logout function and log out listtile widget both defined here
    //Navigator push method has to be part of the postLogout method to correctly invalidate session cookie
    postLogout() async {
      try {
        await http.post('https://www.gig-o-matic.com/api/logout',
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
              color: Color.fromRGBO(14, 39, 96, 1.0), fontSize: 18.0)),
      onTap: () {
        postLogout();
      },
    );
  }
}

//user can add or update a comment for a gig
Future postComment(newComment, planID) async {
  try {
    await http.post('https://www.gig-o-matic.com/api/plan/$planID/comment',
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
    await http.put(
        'https://www.gig-o-matic.com/api/plan/$planID/value/$newValue',
        headers: {"cookie": "${globals.cleanedCookie}"}).then((response) {
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

Future<List> fetchGigMemberInfo(gigID) async {
  List info;
  try {
    final response = await http.get(
        'https://www.gig-o-matic.com/api/gig/plans/$gigID',
        headers: {"cookie": "${globals.cleanedCookie}"});
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

Future<Map> fetchGigDetails(gigID) async {
  Map json;
  try {
    final response = await http.get(
        'https://www.gig-o-matic.com/api/gig/${gigID}',
        headers: {"cookie": "${globals.cleanedCookie}"});
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

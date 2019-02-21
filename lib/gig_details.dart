import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:async/async.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

TextEditingController commentController;

googleMapsAdd(str) {
  //if str contains http do nothing and return str
  RegExp exp = new RegExp(r'http');
  var match = exp.hasMatch(str);
  if (match == true) {
    return str;
  }
  String formattedStr = Uri.encodeFull(str);
  return "http://maps.google.com/?q=" + formattedStr;
}

class GigInfo {
  String gigStatus;
  String gigBand;
  String gigContact;
  String rawDate;
  String gigDate;
  String gigCallTime;
  String gigSetTime;
  String gigEndTime;
  String gigAddress;
  String gigAddressLink;
  String gigPaid;
  String gigLeader;
  String gigPostGig;
  String gigDetails;
  String gigTitle;
  String gigSetList;

  GigInfo(
      {this.gigBand,
      this.gigContact,
      this.gigStatus,
      this.gigDate,
      this.gigAddress,
      this.gigAddressLink,
      this.gigCallTime,
      this.gigDetails,
      this.gigEndTime,
      this.gigLeader,
      this.gigPaid,
      this.gigPostGig,
      this.gigSetTime,
      this.gigTitle,
      this.gigSetList});

  factory GigInfo.fromJson(Map<String, dynamic> json) {
    return GigInfo(
        gigStatus: json["status"].toString(),
        gigBand: json["band"],
        gigContact: json["contact"],
        gigDate: cleanDate(json["date"]),
        gigCallTime: json["calltime"],
        gigSetTime: json["settime"],
        gigEndTime: json["endtime"],
        gigAddress: json["address"],
        gigAddressLink: googleMapsAdd(json["address"]),
        gigPaid: json["paid"],
        gigLeader: json["leader"],
        gigPostGig: json["postgig"],
        gigDetails: json["details"],
        gigTitle: json["title"],
        gigSetList: json["setlist"]);
  }
}

gigText(info, [label]) {
  var result = "$info";

  if (label != null) {
    result = "$label: $info";
  }

  return new Container(
    margin: EdgeInsets.all(5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Expanded(
            child: new Container(
          child: new Text(
            result,
            softWrap: true,
            style: TextStyle(fontSize: 20.0),
          ),
        ))
      ],
    ),
  );
}

gigTextHeader(info) {
  return new Container(
    margin: EdgeInsets.all(5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Expanded(
            child: new Container(
          child: new Text(
            info,
            softWrap: true,
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
        ))
      ],
    ),
  );
}

//Gig Status Explanations
statusText(status) {
  /*
  0 - Pending
  1 - Confirmed
  2 - Cancelled
  */
  if (status == "2") {
    return Text("Cancelled!", style: TextStyle(fontSize: 20.0));
  } else if (status == "1") {
    return Text("Confirmed!", style: TextStyle(fontSize: 20.0));
  } else {
    return Text("Pending", style: TextStyle(fontSize: 20.0));
  }
}

List memberList = [];

class GigDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new GigDetailsState();
}

class GigDetailsState extends State<GigDetails> with TickerProviderStateMixin {
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    commentController.dispose();
    super.dispose();
  }

  //declare var for check icon animation
  AnimationController animationController;
  Animation<double> _fabScale;

  void initState() {
    commentController =
        new TextEditingController(text: globals.currentPlanComment);

    fetchGigMemberInfo().then((result) {
      setState(() {
        memberList = result;
      });
    });

    fetchedGigDetails = fetchGigDetailsInfo();
    //hiding or showing comment text field depending on user comment entered for gig or not
    if (globals.currentPlanComment != "") {
      visibilityComment = true;
      commentButtonText = "Edit Comment";
    }
    if (globals.currentPlanComment == "") {
      visibilityComment = false;
      commentButtonText = "Submit Comment";
    }
    //animation setup for check icon to confirm user comment input sent
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      }
    });

    _fabScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animationController, curve: Curves.bounceOut));

    _fabScale.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  //for comment text field
  FocusNode nodeOne = FocusNode();
  bool visibilityComment = false;
  String commentButtonText = "Error";

  //for setlist
  bool setListIsExpanded = false;

  //user can add or update a comment for a gig
  Future postComment(newComment) async {
    try {
      await http.post(
          'https://www.gig-o-matic.com/api/plan/${globals.currentPlanID}/comment',
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
  Future putStatus(newValue) async {
    try {
      await http.put(
          'https://www.gig-o-matic.com/api/plan/${globals.currentPlanID}/value/$newValue',
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

  //save session cookie to memory
  saveSessionCookie(sessionCookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('sessionCookie', sessionCookie);
    });
  }

  Future<List> fetchGigMemberInfo() async {
    try {
      final response = await http.get(
          'https://www.gig-o-matic.com/api/gig/plans/${globals.currentGigID}',
          headers: {"cookie": "${globals.cleanedCookie}"});
      if (response.statusCode == 200) {
        cleanCookie(response.headers["set-cookie"]);
        saveSessionCookie(globals.cleanedCookie);
      } else {
        print('API call failed, response: ${response.statusCode}');
      }
      var decoded = json.decode(response.body.toString());
      List responseJSON = decoded;
      List newList = [];

      for (int i = 0; i < responseJSON.length; i++) {
        Map newMap = {};
        String name = responseJSON[i]["the_member_name"];
        newMap["name"] = name;
        //commented out code for adding sections info later...
        //String section = responseJSON[i]["the_plan"]["section"];
        //newList.add({"section": section});
        String value = responseJSON[i]["the_plan"]["value"].toString();
        newMap["value"] = value;

        String comment = responseJSON[i]["the_plan"]["comment"];
        if (comment != null) {
          newMap["comment"] = comment;
        }

        newList.add(newMap);
      }

      return newList;
    } catch (e) {
      print(e);
    }
  }

  Future fetchedGigDetails;

  Future<GigInfo> fetchGigDetailsInfo() async {
    try {
      final response = await http.get(
          'https://www.gig-o-matic.com/api/gig/${globals.currentGigID}',
          headers: {"cookie": "${globals.cleanedCookie}"});
      if (response.statusCode == 200) {
        cleanCookie(response.headers["set-cookie"]);
        saveSessionCookie(globals.cleanedCookie);
      } else {
        print('API call failed, response: ${response.statusCode}');
      }

      return GigInfo.fromJson(json.decode(response.body));
    } catch (e) {
      print(e);
    }
  }

  //for updating user status
  Widget newValue = globals.currentPlanIcon;
  String yourStatus = globals.currentPlanDescription;
  int newStatus;
  statusButtons() {
    return new DropdownButton<Widget>(
      items: <Widget>[
        needsValuePlanIconFormatted,
        definitelyPlanIconFormatted,
        probablyPlanIconFormatted,
        dontKnowPlanIconFormatted,
        probablyNotPlanIconFormatted,
        cantDoItPlanIconFormatted,
        notInterestedPlanIconFormatted,
      ].map((Widget val) {
        return new DropdownMenuItem<Widget>(
          value: val,
          child: val,
        );
      }).toList(),
      value: newValue,
      onChanged: (val) {
        newValue = val;
        if (val == needsValuePlanIconFormatted) {
          yourStatus = "Needs Input";
          newStatus = 0;
        } else if (val == definitelyPlanIconFormatted) {
          yourStatus = "Definitely!";
          newStatus = 1;
        } else if (val == probablyPlanIconFormatted) {
          yourStatus = "Probably";
          newStatus = 2;
        } else if (val == dontKnowPlanIconFormatted) {
          yourStatus = "Don't Know";
          newStatus = 3;
        } else if (val == probablyNotPlanIconFormatted) {
          yourStatus = "Probably Not";
          newStatus = 4;
        } else if (val == cantDoItPlanIconFormatted) {
          yourStatus = "Can't Do It";
          newStatus = 5;
        } else if (val == notInterestedPlanIconFormatted) {
          yourStatus = "Not Interested";
          newStatus = 6;
        }
        putStatus(newStatus);
        setState(() {});
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //need initstate to run on return to homepage, to reload current gig information,
        //especially if user has updated status or comment. Disabled default back button and created one
        //that will do so
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Row(children: [
          Container(
            child: FlatButton(
              child: Icon(Icons.arrow_back),
              onPressed: () {
                return Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              child: Text(
                globals.currentBandName,
                softWrap: true,
              ),
            ),
          ),
        ]),
      ),
      body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: FutureBuilder<GigInfo>(
            future: fetchedGigDetails,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        gigTextHeader(globals.currentGigTitle),
                        Container(
                          margin: EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              statusIcons(snapshot.data.gigStatus),
                              Container(
                                margin: EdgeInsets.only(left: 5.0),
                                child: statusText(snapshot.data.gigStatus),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        //gigText(globals.currentGigDate, "Gig Date"),
                        gigText(snapshot.data.gigDate, "Gig Date"),
                        gigText(snapshot.data.gigCallTime, "Call Time"),
                        gigText(snapshot.data.gigSetTime, "Set Time"),
                        gigText(snapshot.data.gigEndTime, "End Time"),
                        new Container(
                          margin: EdgeInsets.all(5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                child: new Text(
                                  "Gig Address: ",
                                  softWrap: true,
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ),
                              new Expanded(
                                  child: new Container(
                                child: FlatButton(
                                  child: Text("${snapshot.data.gigAddress}",
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(14, 39, 96, 1.0),
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    if (await canLaunch(
                                        "${snapshot.data.gigAddressLink}")) {
                                      await launch(
                                          "${snapshot.data.gigAddressLink}");
                                    }
                                  },
                                ),
                              ))
                            ],
                          ),
                        ),
                        gigText(snapshot.data.gigPaid, "Pay"),
                        gigText(snapshot.data.gigLeader, "Leader"),
                        gigText(snapshot.data.gigPostGig, "Post-Gig Plans"),
                        Divider(),
                        gigTextHeader("Details"),
                        gigText(snapshot.data.gigDetails),
                        Divider(),
                        setListIsExpanded
                            ? Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: gigTextHeader("SetList"),
                                      ),
                                      new RawMaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              setListIsExpanded = false;
                                            });
                                          },
                                          child: new Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black,
                                            size: 35.0,
                                          )),
                                    ],
                                  ),
                                  gigText(snapshot.data.gigSetList),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: gigTextHeader("SetList"),
                                  ),
                                  Container(
                                    child: new RawMaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            setListIsExpanded = true;
                                          });
                                        },
                                        child: new Icon(
                                          Icons.arrow_drop_up,
                                          color: Colors.black,
                                          size: 35.0,
                                        )),
                                  ),
                                ],
                              ),

                        Divider(),
                        gigTextHeader("Your Status: "),
                        Container(
                          margin: EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              statusButtons(),
                              new Text(yourStatus,
                                  style: TextStyle(fontSize: 20.0)),
                            ],
                          ),
                        ),
                        //if there is a comment, reveal the comment in textfield, if not, hide text field
                        visibilityComment
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 15.0),
                                      child: new TextField(
                                        focusNode: nodeOne,
                                        controller: commentController,
                                        onSubmitted: (val) {
                                          postComment(val);
                                          //fire the check icon
                                          animationController.forward();
                                        },
                                      ),
                                    ),
                                  ),
                                  //check icon to confirm the user input completed
                                  Transform.scale(
                                    scale: _fabScale.value,
                                    child: Card(
                                      shape: CircleBorder(),
                                      color: Colors.green,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : new Container(),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            onPressed: () {
                              //if a comment exists, clicking the button will focus on the textfield
                              visibilityComment
                                  ? FocusScope.of(context).requestFocus(nodeOne)
                                  //if a comment doesn't exist, clicking the button will reveal text field and change
                                  //the button text to editing
                                  : setState(() {
                                      visibilityComment = true;
                                      commentButtonText = "Edit Comment";
                                    });
                            },
                            child: Text(commentButtonText,
                                style: TextStyle(
                                    color: Color.fromRGBO(14, 39, 96, 1.0),
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Divider(),
                        gigTextHeader("Plans"),
                        Container(margin: EdgeInsets.only(bottom: 20.0)),
                        ListView.builder(
                          //need the physics property set otherwise you will hit an infinity error and can't scroll up!
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: memberList.length,
                          itemBuilder: (context, index) {
                            return Container(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Column(children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 15.0),
                                          child: Text(
                                            '${memberList[index]["name"]}',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                        Container(
                                          child: planValueIcons(
                                              '${memberList[index]["value"]}'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: Text(
                                        '${memberList[index]["comment"]}',
                                        style: TextStyle(fontSize: 15.0)),
                                  ),
                                ]));
                          },
                        ),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: new CircularProgressIndicator(
                  strokeWidth: 3.0,
                  value: null,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          )),
    );
  }
}

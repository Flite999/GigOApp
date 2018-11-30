import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BandInfo {
  String bandName;

  BandInfo({this.bandName});

  factory BandInfo.fromJson(Map<String, dynamic> json) {
    globals.currentBandName = json["name"];

    return BandInfo(bandName: json["name"]);
  }
}

TextEditingController commentController;

class GigInfo {
  String gigStatus;
  String gigBand;
  String gigContact;
  String gigDate;
  String gigCallTime;
  String gigSetTime;
  String gigEndTime;
  String gigAddress;
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
        gigDate: json["date"],
        gigCallTime: json["calltime"],
        gigSetTime: json["settime"],
        gigEndTime: json["endtime"],
        gigAddress: json["address"],
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

Future<GigInfo> fetchGigInfo() async {
  try {
    final response = await http.get(
        'https://www.gig-o-matic.com/api/gig/${globals.currentGigID}',
        headers: {"cookie": "${globals.cleanedCookie}"});
    return GigInfo.fromJson(json.decode(response.body));
  } catch (e) {
    print(e);
  }
}

//user can update their status for a gig
Future putStatus(newValue) async {
  try {
    await http.put(
        'https://www.gig-o-matic.com/api/plan/${globals.currentPlanID}/value/$newValue',
        headers: {"cookie": "${globals.cleanedCookie}"});
  } catch (e) {
    print(e);
  }
}

//user can add or update a comment for a gig
Future postComment(newComment) async {
  try {
    await http.post(
        'https://www.gig-o-matic.com/api/plan/${globals.currentPlanID}/comment',
        headers: {"cookie": "${globals.cleanedCookie}"},
        body: {"comment": "$newComment"});
  } catch (e) {
    print(e);
  }
}

Future<BandInfo> fetchBandName(bandID) async {
  try {
    final response = await http.get(
        'https://www.gig-o-matic.com/api/band/$bandID',
        headers: {"cookie": "${globals.cleanedCookie}"});
    return BandInfo.fromJson(json.decode(response.body));
  } catch (e) {
    print("Fetching Band Name from Band ID: $e");
  }
}

class GigDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new GigDetailsState();
}

class GigDetailsState extends State<GigDetails> {
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    commentController.dispose();
    super.dispose();
  }

  void initState() {
    commentController =
        new TextEditingController(text: globals.currentPlanComment);
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
        backgroundColor: Colors.blue,
        title: Row(children: [
          FutureBuilder<BandInfo>(
            future: fetchBandName(globals.currentBandID),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: Container(
                    child: Text(snapshot.data.bandName),
                  ),
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
          )
        ]),
      ),
      body: Container(
          color: Color.fromRGBO(150, 248, 157, 1.0),
          padding: EdgeInsets.all(10.0),
          child: FutureBuilder<GigInfo>(
            future: fetchGigInfo(),
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
                        gigText(globals.currentGigDate),
                        gigText(snapshot.data.gigCallTime, "Call Time"),
                        gigText(snapshot.data.gigSetTime, "Set Time"),
                        gigText(snapshot.data.gigEndTime, "End Time"),
                        gigText(snapshot.data.gigAddress),
                        gigText(snapshot.data.gigPaid, "Pay"),
                        gigText(snapshot.data.gigLeader, "Leader"),
                        gigText(snapshot.data.gigPostGig, "Post-Gig Plans"),
                        Divider(),
                        gigTextHeader("Details"),
                        gigText(snapshot.data.gigDetails),
                        Divider(),
                        gigTextHeader("SetList"),
                        gigText(snapshot.data.gigSetList),
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
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: new TextField(
                              controller: commentController,
                              onSubmitted: (val) {
                                postComment(val);
                              },
                              decoration: InputDecoration(
                                  helperText: "Comment Here",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white)),
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

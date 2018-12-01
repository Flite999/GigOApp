import 'package:flutter/material.dart';
import 'login_page.dart';
import 'gig_details.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

String cleanedDate;
var statusIcon;
String bandID;
String bandName;

gigTitles(String title) {
  return new Text("$title");
}

//format date for readability
cleanDate(date) {
  RegExp upToSpace = new RegExp(r".*(?=[ ])");
  String str = date;
  cleanedDate = upToSpace.stringMatch(str).toString();
  globals.currentGigDate = cleanedDate;
}

Widget cancelledStatusIconFormatted =
    Icon(FontAwesomeIcons.solidTimesCircle, size: 25.0, color: Colors.red);

Widget confirmedStatusIconFormatted =
    Icon(FontAwesomeIcons.solidCheckCircle, size: 25.0, color: Colors.green);

Widget pendingStatusIconFormatted = Icon(FontAwesomeIcons.solidQuestionCircle,
    size: 25.0, color: Colors.yellow);

//gig status icons
statusIcons(status) {
  /*
  0 - Pending
  1 - Confirmed
  2 - Cancelled
  */
  if (status == "2") {
    return cancelledStatusIconFormatted;
  } else if (status == "1") {
    return confirmedStatusIconFormatted;
  } else {
    return pendingStatusIconFormatted;
  }
}

Widget needsValuePlanIconFormatted = Icon(
  FontAwesomeIcons.minus,
  size: 25.0,
);

Widget definitelyPlanIconFormatted = Icon(
  FontAwesomeIcons.solidCircle,
  size: 25.0,
  color: Colors.green,
);

Widget probablyPlanIconFormatted = Icon(
  FontAwesomeIcons.circle,
  size: 25.0,
  color: Colors.green,
);

Widget dontKnowPlanIconFormatted = Icon(
  FontAwesomeIcons.question,
  size: 25.0,
  color: Colors.grey,
);

Widget probablyNotPlanIconFormatted = Icon(
  FontAwesomeIcons.square,
  size: 25.0,
  color: Colors.red,
);

Widget cantDoItPlanIconFormatted = Icon(
  FontAwesomeIcons.solidSquare,
  size: 25.0,
  color: Colors.red,
);

Widget notInterestedPlanIconFormatted = Icon(
  FontAwesomeIcons.times,
  size: 25.0,
);

//user status icons
planValueIcons(value) {
  /*
  0 - needs value
  1 - Definitely
  2 - Probably
  3 - Don't Know
  4 - Probably Not
  5 - Can't Do It
  6 - Not Interested
  */
  if (value == "0") {
    return needsValuePlanIconFormatted;
  } else if (value == "1") {
    return definitelyPlanIconFormatted;
  } else if (value == "2") {
    return probablyPlanIconFormatted;
  } else if (value == "3") {
    return dontKnowPlanIconFormatted;
  } else if (value == "4") {
    return probablyNotPlanIconFormatted;
  } else if (value == "5") {
    return cantDoItPlanIconFormatted;
  } else {
    return notInterestedPlanIconFormatted;
  }
}

//for just returning user status icons and not the widgets
planValueIconsNoFormat(value) {
  /*
  0 - needs value
  1 - Definitely
  2 - Probably
  3 - Don't Know
  4 - Probably Not
  5 - Can't Do It
  6 - Not Interested
  */
  if (value == "0") {
    return needsValuePlanIconFormatted;
  } else if (value == "1") {
    return definitelyPlanIconFormatted;
  } else if (value == "2") {
    return probablyPlanIconFormatted;
  } else if (value == "3") {
    return dontKnowPlanIconFormatted;
  } else if (value == "4") {
    return probablyNotPlanIconFormatted;
  } else if (value == "5") {
    return cantDoItPlanIconFormatted;
  } else {
    return notInterestedPlanIconFormatted;
  }
}

//returns user status values
planValueLabelGenerator(value) {
  /*
  0 - needs value
  1 - Definitely
  2 - Probably
  3 - Don't Know
  4 - Probably Not
  5 - Can't Do It
  6 - Not Interested
  */
  if (value == "0") {
    return "Needs Input";
  } else if (value == "1") {
    return "Definitely!";
  } else if (value == "2") {
    return "Probably";
  } else if (value == "3") {
    return "Don't Know";
  } else if (value == "4") {
    return "Probably Not";
  } else if (value == "5") {
    return "Can't Do It";
  } else {
    return "Not Interested";
  }
}

postLogout() async {
  try {
    await http.get('https://www.gig-o-matic.com/api/logout',
        headers: {"cookie": "${globals.cleanedCookie}"});
  } catch (e) {}
}

class Gig {
  String title;
  String date;
  String status;
  String planValue;
  String planValueLabel;
  String planComment;
  String planID;
  String gigID;
  String bandID;

  Gig({
    this.title,
    this.date,
    this.status,
    this.planValue,
    this.planValueLabel,
    this.planComment,
    this.planID,
    this.gigID,
    this.bandID,
  });
}

List<Gig> createGigList(List data, List data2) {
  List<Gig> list = new List();

  //Weigh In Plans
  for (int i = 0; i < data.length; i++) {
    String title = data[i]["gig"]["title"];
    String rawDate = data[i]["gig"]["date"];
    cleanDate(rawDate);
    String status = data[i]["gig"]["status"].toString();
    String planValue = data[i]["plan"]["value"].toString();
    String planValueLabel =
        planValueLabelGenerator(data[i]["plan"]["value"].toString());
    String planComment = data[i]["plan"]["comment"];
    String planID = data[i]["plan"]["id"];
    if (planComment == "") {
      planComment = "...";
    }
    String gigID = data[i]["gig"]["id"];
    String bandID = data[i]["gig"]["band"].toString();

    Gig gig = new Gig(
      title: title,
      date: cleanedDate,
      status: status,
      planValue: planValue,
      planValueLabel: planValueLabel,
      planComment: planComment,
      planID: planID,
      gigID: gigID,
      bandID: bandID,
    );
    list.add(gig);
  }

  //Upcoming Plans
  for (int i = 0; i < data2.length; i++) {
    String title = data2[i]["gig"]["title"];
    String rawDate = data2[i]["gig"]["date"];
    cleanDate(rawDate);
    String status = data2[i]["gig"]["status"].toString();
    String planValue = data2[i]["plan"]["value"].toString();
    String planValueLabel =
        planValueLabelGenerator(data2[i]["plan"]["value"].toString());
    String planComment = data2[i]["plan"]["comment"];
    String planID = data2[i]["plan"]["id"];
    if (planComment == "") {
      planComment = "...";
    }
    String gigID = data2[i]["gig"]["id"];
    String bandID = data2[i]["gig"]["band"].toString();

    Gig gig = new Gig(
      title: title,
      date: cleanedDate,
      status: status,
      planValue: planValue,
      planValueLabel: planValueLabel,
      planComment: planComment,
      planID: planID,
      gigID: gigID,
      bandID: bandID,
    );
    list.add(gig);
  }

  return list;
}

Future<List<Gig>> fetchGigInfo() async {
  try {
    final response = await http.get('https://www.gig-o-matic.com/api/agenda',
        headers: {"cookie": "${globals.cleanedCookie}"});
    Map decoded = json.decode(response.body.toString());
    List responseJSON = decoded["weighin_plans"];
    List responseJSON2 = decoded["upcoming_plans"];

    List<Gig> gigList = createGigList(responseJSON, responseJSON2);

    return gigList;
  } catch (e) {
    print(e);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {}

  //builds dynamic list from API
  gigBuilder() {
    return Flexible(
      fit: FlexFit.loose,
      child: new FutureBuilder<List<Gig>>(
          future: fetchGigInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (content, index) {
                    return new Column(children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: 15.0, bottom: 10.0, left: 5.0, right: 5.0),
                        child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(left: 10.0, right: 5.0),
                                child: statusIcons(snapshot.data[index].status),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: FlatButton(
                                      child: Text(snapshot.data[index].title,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        //To Gig Details->global variables passed from here to specific gig details
                                        globals.currentBandID =
                                            snapshot.data[index].bandID;
                                        globals.currentPlanComment =
                                            snapshot.data[index].planComment;
                                        globals.currentPlanID =
                                            snapshot.data[index].planID;
                                        globals.currentPlanDescription =
                                            snapshot.data[index].planValueLabel;
                                        globals.currentPlanIcon =
                                            planValueIconsNoFormat(
                                                snapshot.data[index].planValue);
                                        globals.currentPlanValue =
                                            snapshot.data[index].planValue;
                                        globals.currentGigTitle =
                                            snapshot.data[index].title;
                                        globals.currentGigID =
                                            snapshot.data[index].gigID;
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GigDetails()));
                                      }),
                                ),
                              ),
                            ]),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 15.0),
                        child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //new Divider(),
                              Container(
                                  child: Expanded(
                                child: Text(snapshot.data[index].date,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold)),
                              )),
                              new Divider(),
                              Container(
                                child: planValueIcons(
                                    snapshot.data[index].planValue),
                              ),
                              new Divider(),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: new Text(
                                      snapshot.data[index].planComment),
                                ),
                              )
                            ]),
                      ),
                    ]);
                  });
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            }
            return Center(
              child: new CircularProgressIndicator(
                strokeWidth: 3.0,
                value: null,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Upcoming Gigs"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        color: Color.fromRGBO(150, 248, 157, 1.0),
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                decoration: new BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1.0, style: BorderStyle.solid))),
                child: Column(
                  children: <Widget>[
                    gigBuilder(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Container(
        width: 200.0,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 120.0,
                child: DrawerHeader(
                  child: Text('Menu',
                      style: TextStyle(color: Colors.black, fontSize: 18.0)),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
              ),
              ListTile(
                title: Text('Log Out', style: TextStyle(fontSize: 18.0)),
                onTap: () {
                  postLogout();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

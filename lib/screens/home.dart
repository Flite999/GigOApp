import 'package:flutter/material.dart';
import 'gig_details.dart';
import '../utils/globals.dart' as globals;
import 'dart:async';
import '../utils/formatTools.dart';
import '../utils/classes.dart';
import '../utils/apiTools.dart';
import '../utils/buildTools.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    //calls the gig info once and saves it
    fetchedInfo = buildGigList();

    //buildSectionList here for use in rest of the app
    buildSectionList();
    super.initState();
  }

  //var to store gig info from agenda call.
  //Declared here and data populated once the MyHomePageState widget gets built.
  Future fetchedInfo;

  //builds dynamic list from API
  gigBuilder() {
    return Flexible(
      fit: FlexFit.loose,
      child: new FutureBuilder<List<Gig>>(
          //fetchedInfo is used for future property, which means "cached" agenda data is reused each time the
          //widget rebuilds, rather than the API being called over and over as a user navigates through a long list of gigs.
          //(the agenda api is still called when navigating to app_home)
          future: fetchedInfo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (content, index) {
                    return new Container(
                        margin: EdgeInsets.only(bottom: 5.0),
                        decoration: new BoxDecoration(
                          border: new Border(
                            left: new BorderSide(
                                color: Colors.grey,
                                width: 5.0,
                                style: BorderStyle.solid),
                          ),
                        ),
                        child: new Column(children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                top: 15.0, bottom: 10.0, left: 5.0, right: 5.0),
                            child: new Row(children: [
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
                                              color: Color.fromRGBO(
                                                  14, 39, 96, 1.0),
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        //To Gig Details->global variables passed from here to specific gig details
                                        globals.currentBandName =
                                            snapshot.data[index].bandLongName;
                                        globals.currentBandID =
                                            snapshot.data[index].bandID;
                                        globals.currentPlanComment =
                                            snapshot.data[index].planComment;
                                        globals.currentPlanID =
                                            snapshot.data[index].planID;
                                        globals.currentPlanDescription =
                                            snapshot.data[index].planValueLabel;
                                        globals.currentPlanIcon =
                                            planValueIcons(
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
                              Container(
                                  child: Text(
                                      "(${snapshot.data[index].bandShortName})")),
                            ]),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15.0),
                            child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      child: Expanded(
                                    child: Text(snapshot.data[index].date,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        )),
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
                        ]));
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
        color: Colors.white,
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
                      style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
              ),
              LogoutTile(),
              Container(
                padding: EdgeInsets.only(left: 15.0),
                alignment: Alignment.bottomLeft,
                child: Text("App Version: 1.0"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

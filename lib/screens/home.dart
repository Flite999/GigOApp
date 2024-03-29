import 'package:flutter/material.dart';
import 'gig_details.dart';
import 'dart:async';
import '../utils/formatTools.dart';
import '../utils/classes.dart';
import '../utils/apiTools.dart';
import '../utils/buildTools.dart';
import '../utils/statusButtons.dart';
import '../utils/gigComment.dart';

//GigData class for passing data from home screen to gig details page
class GigData {
  String? currentBandName;
  String? currentBandID;
  String? currentPlanComment;
  String? currentPlanID;
  String? currentPlanDescription;
  var currentPlanIcon;
  String? currentPlanValue;
  String? currentGigTitle;
  String? currentGigID;
  GigData(
      {this.currentBandID,
      this.currentPlanComment,
      this.currentPlanID,
      this.currentPlanDescription,
      this.currentPlanIcon,
      this.currentPlanValue,
      this.currentGigID,
      this.currentGigTitle,
      this.currentBandName});
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    //buildSectionList here for use in rest of the app
    buildSectionList();
    super.initState();
    //calls the gig info once and saves it
    fetchedInfo = buildGigList();
  }

  //var to store gig info from agenda call.
  //Declared here and data populated once the MyHomePageState widget gets built.
  Future? fetchedInfo;

  //builds dynamic list from API
  gigBuilder() {
    return Flexible(
      fit: FlexFit.loose,
      child: new FutureBuilder<List<Gig>>(
          //fetchedInfo is used for future property, which means "cached" agenda data is reused each time the
          //widget rebuilds, rather than the API being called over and over as a user navigates through a long list of gigs.
          //(the agenda api is still called when navigating to app_home)
          future: fetchedInfo as Future<List<Gig>>?,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (content, index) {
                    return new Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(15.0),
                          border: Border.all(
                              color: Colors.green,
                              width: 2.0,
                              style: BorderStyle.solid),
                        ),
                        child: new Column(children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                top: 15.0, left: 5.0, right: 5.0),
                            child: new Row(children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(left: 10.0, right: 5.0),
                                child: statusIcons(snapshot.data![index].status),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: FlatButton(
                                      child: Text(snapshot.data![index].title!,
                                          softWrap: true,
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  14, 39, 96, 1.0),
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        //create a data object here with all the current gig vars and pass to gig details page...todo-explore just using the gig class used for building the gig list instead of the GigData class
                                        final gigData = GigData(
                                            currentBandName: snapshot
                                                .data![index].bandLongName,
                                            currentBandID:
                                                snapshot.data![index].bandID,
                                            currentPlanComment: snapshot
                                                .data![index].planComment,
                                            currentPlanID:
                                                snapshot.data![index].planID,
                                            currentPlanDescription: snapshot
                                                .data![index].planValueLabel,
                                            currentPlanIcon: planValueIcons(
                                                snapshot.data![index].planValue),
                                            currentPlanValue:
                                                snapshot.data![index].planValue,
                                            currentGigTitle:
                                                snapshot.data![index].title,
                                            currentGigID:
                                                snapshot.data![index].gigID);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GigDetails(
                                                        gigData: gigData)));
                                      }),
                                ),
                              ),
                              Container(
                                  child: Text(
                                      "(${snapshot.data![index].bandShortName})")),
                            ]),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15.0),
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 15.0),
                                    child: Text(snapshot.data![index].date!,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        )),
                                  ),
                                  StatusButtons(
                                    planID: snapshot.data![index].planID,
                                    userStatus:
                                        snapshot.data![index].planValueLabel,
                                    newValue: planValueIcons(
                                        snapshot.data![index].planValue),
                                    bandName: snapshot.data![index].bandLongName,
                                  ),
                                  new Divider(),
                                ]),
                          ),
                          //interesting behavior here - when comment is entered and you navigate to gig details, the comment is not updated, due to the listview already built. I don't think rebuilding the listview everytime a comment is updated would be great user experience, so will have to keep thinking about this one. Same behavior for statusbuttons as well, of course.
                          GigComment(
                              planComment: snapshot.data![index].planComment,
                              planID: snapshot.data![index].planID)
                        ]));
                  });
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            } else {
              return Center(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text("Loading Gigs", style: TextStyle(fontSize: 25.0)),
                    Divider(color: Colors.white),
                    new CircularProgressIndicator(
                      strokeWidth: 3.0,
                      value: null,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ],
                ),
              );
            }
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
                      style: TextStyle(color: Colors.white, fontSize: 22.0)),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
              ),
              LogoutTile(),
              Container(
                padding: EdgeInsets.only(left: 15.0),
                alignment: Alignment.bottomLeft,
                child:
                    Text("App Version: 1.5", style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'formatTools.dart';
import 'apiTools.dart';
import 'package:flutter/foundation.dart';

class StatusButtons extends StatefulWidget {
  final String userStatus;
  final newValue;
  final planID;
  const StatusButtons(
      {Key key,
      @required this.userStatus,
      @required this.newValue,
      @required this.planID})
      : super(key: key);
  @override
  StatusButtonsState createState() => StatusButtonsState(
      userStatus: this.userStatus,
      newValue: this.newValue,
      planID: this.planID);
}

class StatusButtonsState extends State<StatusButtons> {
  String userStatus;
  Widget newValue;
  String planID;

  StatusButtonsState({this.userStatus, this.newValue, this.planID});
  //value needs to be set for the class each time it is created, add as required field.
  //then can set this as a value for each gig on the homepage and pass through
  statusButtons() {
    int newStatus;
    return new DropdownButton<Widget>(
      onChanged: (val) {
        newValue = val;
        if (val == needsValuePlanIconFormatted) {
          userStatus = "Needs Input";
          newStatus = 0;
        } else if (val == definitelyPlanIconFormatted) {
          userStatus = "Definitely!";
          newStatus = 1;
        } else if (val == probablyPlanIconFormatted) {
          userStatus = "Probably";
          newStatus = 2;
        } else if (val == dontKnowPlanIconFormatted) {
          userStatus = "Don't Know";
          newStatus = 3;
        } else if (val == probablyNotPlanIconFormatted) {
          userStatus = "Probably Not";
          newStatus = 4;
        } else if (val == cantDoItPlanIconFormatted) {
          userStatus = "Can't Do It";
          newStatus = 5;
        } else if (val == notInterestedPlanIconFormatted) {
          userStatus = "Not Interested";
          newStatus = 6;
        }

        putStatus(newStatus, planID);
        setState(() {});
      },
      value: newValue,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          statusButtons(),
          new Text(userStatus, style: TextStyle(fontSize: 20.0)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'formatTools.dart';
import 'apiTools.dart';
import 'package:flutter/foundation.dart';
import 'globals.dart' as globals;

class StatusButtons extends StatefulWidget {
  final String? userStatus;
  final newValue;
  final planID;
  final String? bandName;
  const StatusButtons(
      {Key? key,
      required this.userStatus,
      required this.newValue,
      required this.planID,
      required this.bandName})
      : super(key: key);
  @override
  StatusButtonsState createState() => StatusButtonsState(
      userStatus: this.userStatus,
      newValue: this.newValue,
      planID: this.planID,
      bandName: this.bandName);
}

class StatusButtonsState extends State<StatusButtons> {
  String? bandName;
  String? userStatus;
  Widget? newValue;
  String? planID;

  StatusButtonsState(
      {this.userStatus, this.newValue, this.planID, this.bandName});

  statusButtons() {
    int? newStatus;
    //check if band has simple options turned on
    bool? simpleOptionsOn;
    try {
      for (int i = 0; i < globals.bandList!.length; i++) {
        if (bandName == globals.bandList![i].name &&
            globals.bandList![i].simpleOptions == true) {
          simpleOptionsOn = true;
        }
      }
    } catch (e) {
      print('Error');
    }
    //if simple options are on
    if (simpleOptionsOn == true) {
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
          dontKnowPlanIconFormatted,
          definitelyPlanIconFormatted,
          cantDoItPlanIconFormatted,
        ].map((Widget val) {
          return new DropdownMenuItem<Widget>(
            value: val,
            child: val,
          );
        }).toList(),
      );
    }

    //if simple options off
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
          new Text(userStatus!, style: TextStyle(fontSize: 20.0)),
        ],
      ),
    );
  }
}

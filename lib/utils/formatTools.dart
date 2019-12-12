//formatting tools for app
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'globals.dart' as globals;

Widget cancelledStatusIconFormatted =
    Icon(FontAwesomeIcons.solidTimesCircle, size: 25.0, color: Colors.red);

Widget confirmedStatusIconFormatted =
    Icon(FontAwesomeIcons.solidCheckCircle, size: 25.0, color: Colors.green);

Widget pendingStatusIconFormatted = Icon(FontAwesomeIcons.solidQuestionCircle,
    size: 25.0, color: Colors.yellow);

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

gigTitles(String title) {
  return new Text("$title");
}

//format date for readability
cleanDate(date) {
  RegExp upToSpace = new RegExp(r".*(?=[ ])");
  String str = date;
  String cleanedDate = upToSpace.stringMatch(str).toString();
  return cleanedDate;
}

//gig status icons
statusIcons(status) {
  /*
  0 - Pending
  1 - Confirmed
  2 - Cancelled
  */

  switch (status) {
    case "2":
      {
        return cancelledStatusIconFormatted;
      }
      break;
    case "1":
      {
        return confirmedStatusIconFormatted;
      }
      break;
    default:
      {
        return pendingStatusIconFormatted;
      }
      break;
  }
}

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

  switch (value) {
    case "0":
      {
        return needsValuePlanIconFormatted;
      }
      break;
    case "1":
      {
        return definitelyPlanIconFormatted;
      }
      break;
    case "2":
      {
        return probablyPlanIconFormatted;
      }
      break;
    case "3":
      {
        return dontKnowPlanIconFormatted;
      }
      break;
    case "4":
      {
        return probablyNotPlanIconFormatted;
      }
      break;
    case "5":
      {
        return cantDoItPlanIconFormatted;
      }
      break;
    default:
      {
        return notInterestedPlanIconFormatted;
      }
      break;
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

  switch (value) {
    case "0":
      {
        return "Needs Input";
      }
      break;
    case "1":
      {
        return "Definitely!";
      }
      break;
    case "2":
      {
        return "Probably";
      }
      break;
    case "3":
      {
        return "Don't Know";
      }
      break;
    case "4":
      {
        return "Probably Not";
      }
      break;
    case "5":
      {
        return "Can't Do It";
      }
      break;
    default:
      {
        return "Not Interested";
      }
      break;
  }
}

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

gigTextBold(info, [label]) {
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
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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

//function takes section ID and returns a name for that section
returnSectionName(id) {
  //for each section instance in list, if id key equals id, return the name
  for (int i = 0; i < globals.sectionList.length; i++) {
    if (id == null) {
      return "No Section";
    }
    if (id == "") {
      return "No Section";
    }
    if (id == globals.sectionList[i].id) {
      return globals.sectionList[i].name;
    }
  }
}

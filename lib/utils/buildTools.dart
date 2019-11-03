import 'dart:async';
import 'dart:ffi';
import 'package:gig_o/utils/apiTools.dart';
import 'classes.dart';
import 'formatTools.dart';
import 'globals.dart' as globals;
//import '../screens/gig_details.dart';

//need bandIDs from agenda endpoint to correctly reach out to bandSection endpoint
compileBandIDs() async {
  final Map agenda = await fetchAgenda();
  List weighInPlans = agenda["weighin_plans"];
  List upcomingPlans = agenda["upcoming_plans"];
  List compiledBandIDs = [];
  for (int i = 0; i < weighInPlans.length; i++) {
    String bandID = weighInPlans[i]["gig"]["band"].toString();
    compiledBandIDs.add(bandID);
  }
  for (int i = 0; i < upcomingPlans.length; i++) {
    String bandID = upcomingPlans[i]["gig"]["band"].toString();
    compiledBandIDs.add(bandID);
  }
  return compiledBandIDs.toSet().toList();
}

//to-do: works for now, but need to change function to a List object, shouldn't be a future
Future<List> buildSectionList() async {
  List bandIDs = await compileBandIDs();
  Map bandSectionMap = await fetchBandSections(bandIDs);
  List bandSections = bandSectionMap["sections"];
  List<Section> list = new List();

  for (int i = 0; i < bandSections.length; i++) {
    String name = bandSections[i]["name"];
    String id = bandSections[i]['id'];
    Section section = new Section(
      name: name,
      id: id,
    );
    list.add(section);
  }
  globals.sectionList = list;
}

//has to be a future class for the fetchedInfo var to be used in the app_home FutureBuilder Class
Future<List<Gig>> buildGigList() async {
  Map json = await fetchAgenda();
  //to-do: eliminate this duplicated code here to build the two different categories of gigs
  List weighinPlans = json["weighin_plans"];
  List upcomingPlans = json["upcoming_plans"];

  List<Gig> list = new List();

  //Weigh In Plans
  for (int i = 0; i < weighinPlans.length; i++) {
    String title = weighinPlans[i]["gig"]["title"];
    String date = cleanDate(weighinPlans[i]["gig"]["date"]);
    String status = weighinPlans[i]["gig"]["status"].toString();
    String planValue = weighinPlans[i]["plan"]["value"].toString();
    String planValueLabel =
        planValueLabelGenerator(weighinPlans[i]["plan"]["value"].toString());
    String planComment = weighinPlans[i]["plan"]["comment"];
    String planID = weighinPlans[i]["plan"]["id"];
    String gigID = weighinPlans[i]["gig"]["id"];
    String bandID = weighinPlans[i]["gig"]["band"].toString();
    String bandShortName = weighinPlans[i]["band"]["shortname"];
    String bandLongName = weighinPlans[i]["band"]["name"];

    Gig gig = new Gig(
      title: title,
      date: date,
      status: status,
      planValue: planValue,
      planValueLabel: planValueLabel,
      planComment: planComment,
      planID: planID,
      gigID: gigID,
      bandID: bandID,
      bandShortName: bandShortName,
      bandLongName: bandLongName,
    );
    list.add(gig);
  }

  //Upcoming Plans

  for (int i = 0; i < upcomingPlans.length; i++) {
    String title = upcomingPlans[i]["gig"]["title"];
    String date = cleanDate(upcomingPlans[i]["gig"]["date"]);
    String status = upcomingPlans[i]["gig"]["status"].toString();
    String planValue = upcomingPlans[i]["plan"]["value"].toString();
    String planValueLabel =
        planValueLabelGenerator(upcomingPlans[i]["plan"]["value"].toString());
    String planComment = upcomingPlans[i]["plan"]["comment"];
    String planID = upcomingPlans[i]["plan"]["id"];
    String gigID = upcomingPlans[i]["gig"]["id"];
    String bandID = upcomingPlans[i]["gig"]["band"].toString();
    String bandShortName = upcomingPlans[i]["band"]["shortname"];
    String bandLongName = upcomingPlans[i]["band"]["name"];

    Gig gig = new Gig(
      title: title,
      date: date,
      status: status,
      planValue: planValue,
      planValueLabel: planValueLabel,
      planComment: planComment,
      planID: planID,
      gigID: gigID,
      bandID: bandID,
      bandShortName: bandShortName,
      bandLongName: bandLongName,
    );
    list.add(gig);
  }

  return list;
}

Future<GigInfo> buildGigInfo() async {
  var gigInfo = new GigInfo();
  Map json = await fetchGigDetails();
  gigInfo = GigInfo.fromJson(json);
  return gigInfo;
}

Future<List> buildGigMemberList() async {
  List newList = [];
  List json = await fetchGigMemberInfo();
  for (int i = 0; i < json.length; i++) {
    Map newMap = {};
    String name = json[i]["the_member_name"].toString();
    newMap["name"] = name;
    newMap["section"] =
        returnSectionName(json[i]["the_plan"]["section"].toString());
    if (newMap["section"] == null) {
      newMap["section"] = "";
    }
    String value = json[i]["the_plan"]["value"].toString();
    newMap["value"] = value;

    String comment = json[i]["the_plan"]["comment"];

    if (comment != null) {
      newMap["comment"] = comment;
    } else {
      newMap["comment"] = "";
    }

    newList.add(newMap);
  }
  if (newList.length > 1) {
    newList.sort((a, b) {
      return a["section"].compareTo(b["section"]);
    });
  }
  return newList;
  //Ideally this function is where the logic would go to add section headers for each section. However
  //the newList variable gets polluted somehow after it goes through the loop and can't be manipulated
  //after the fact. Will address later.
  //after list is sorted due to section name, the section name would be added to the newList.
  /*
      List alterationsList = [];

      for (int i = 1; i < newList.length; i++) {
        
        if (newList[i]["section"] != newList[i - 1]["section"]) {
        Map alterationsMap = <String, dynamic>{};
        String toAdd = newList[i]["section"];
        int index = i;

        alterationsMap["index"] = index.toInt();

        alterationsMap["value"] = toAdd;
        alterationsList.add([index, toAdd]);
        }
        
      }
  */
}

calculateCriticalMassPercent(memberList) {
  int memberCount = 0;
  int countYes = 0;
  int percent;
  for (int i = 0; i < memberList.length; i++) {
    memberCount++;
    switch (memberList[i]['value']) {
      case '1':
        countYes++;
        break;
      case '2':
        countYes++;
        break;
      default:
        break;
    }
    /*if (memberList[i]['value'] == "1"  memberList[i]['value'] == "2") {
      countYes++;
    }*/
  }
  if (memberCount != 0) {
    percent = ((countYes / memberCount) * 100).round();
  } else {
    percent = 0;
  }

  return percent;
}

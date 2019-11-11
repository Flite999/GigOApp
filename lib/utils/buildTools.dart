import 'dart:async' show Future;
import 'package:gig_o/utils/apiTools.dart';
import 'classes.dart';
import 'formatTools.dart';
import 'globals.dart' as globals;

Future<GigInfo> buildGigInfo() async {
  var gigInfo = new GigInfo();
  Map json = await fetchGigDetails();
  gigInfo = GigInfo.fromJson(json);
  return gigInfo;
}

List<Gig> buildGigFromJSON(plans) {
  List<Gig> list = new List();

  //Weigh In Plans
  for (int i = 0; i < plans.length; i++) {
    String title = plans[i]["gig"]["title"];
    String date = cleanDate(plans[i]["gig"]["date"]);
    String status = plans[i]["gig"]["status"].toString();
    String planValue = plans[i]["plan"]["value"].toString();
    String planValueLabel =
        planValueLabelGenerator(plans[i]["plan"]["value"].toString());
    String planComment = plans[i]["plan"]["comment"];
    String planID = plans[i]["plan"]["id"];
    String gigID = plans[i]["gig"]["id"];
    String bandID = plans[i]["gig"]["band"].toString();
    String bandShortName = plans[i]["band"]["shortname"];
    String bandLongName = plans[i]["band"]["name"];

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

//has to be a future class for the fetchedInfo var to be used in the app_home FutureBuilder Class
Future<List<Gig>> buildGigList() async {
  Map json = await fetchAgenda();
  List weighinPlans = json["weighin_plans"];
  List upcomingPlans = json["upcoming_plans"];

  List<Gig> weighinPlansList = new List();
  List<Gig> upcomingPlansList = new List();

  weighinPlansList = buildGigFromJSON(weighinPlans);
  upcomingPlansList = buildGigFromJSON(upcomingPlans);

  List<Gig> combinedList = [...weighinPlansList, ...upcomingPlansList];
  return combinedList;
}

List buildGigMemberSectionList(gigMemberList) {
  List initialList = new List();
  List finalList = new List();
  for (int i = 0; i < gigMemberList.length; i++) {
    initialList.add(gigMemberList[i]['section']);
  }
  //remove duplicate section entries
  finalList = initialList.toSet().toList();

  return finalList;
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

  List gigMemberSectionList = buildGigMemberSectionList(newList);
  print(gigMemberSectionList);

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

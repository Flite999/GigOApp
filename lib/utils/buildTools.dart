import 'dart:async' show Future;
import 'package:gig_o/utils/apiTools.dart';
import 'classes.dart';
import 'formatTools.dart';
import 'globals.dart' as globals;

Future<GigInfo> buildGigInfo(gigID) async {
  var gigInfo = new GigInfo();
  Map json = await fetchGigDetails(gigID);
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

Future<List> buildGigMemberList(gigID) async {
  List gigMemberList = [];
  List gigMemberInfo = await fetchGigMemberInfo(gigID);

  for (int i = 0; i < gigMemberInfo.length; i++) {
    //to-do: this map construction should be abstracted to a class
    Map memberMap = {};

    //build name
    String name = gigMemberInfo[i]["the_member_name"].toString();
    memberMap["name"] = name;

    //build section and check for null
    memberMap["section"] =
        returnSectionName(gigMemberInfo[i]["the_plan"]["section"].toString());
    if (memberMap["section"] == null) {
      memberMap["section"] = "";
    }

    //build response
    String value = gigMemberInfo[i]["the_plan"]["value"].toString();
    memberMap["value"] = value;

    //build comment and check for null
    String comment = gigMemberInfo[i]["the_plan"]["comment"];
    if (comment != null) {
      memberMap["comment"] = comment;
    } else {
      memberMap["comment"] = "";
    }

    gigMemberList.add(memberMap);
  }

  List gigMemberSectionList = buildGigMemberSectionList(gigMemberList);

  //sort section alphabetically
  if (gigMemberList.length > 1) {
    gigMemberList.sort((a, b) {
      return a["section"].compareTo(b["section"]);
    });
  }

  List compiledGigMemberList = [];
  for (int x = 0; x < gigMemberSectionList.length; x++) {
    List sectionList = [];
    String sectionTitle = gigMemberSectionList[x];
    Map sectionMap = {};
    sectionMap['sectionTitle'] = sectionTitle;
    Map memberMap;

    for (int y = 0; y < gigMemberList.length; y++) {
      if (gigMemberSectionList[x] == gigMemberList[y]['section']) {
        memberMap = gigMemberList[y];
        sectionList.add(memberMap);
      }
    }

    sectionMap['members'] = sectionList;
    compiledGigMemberList.add(sectionMap);
  }
  return compiledGigMemberList;
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
  }
  if (memberCount != 0) {
    percent = ((countYes / memberCount) * 100).round();
  } else {
    percent = 0;
  }

  return percent;
}

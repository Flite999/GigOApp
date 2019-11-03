//Class definitions here
import 'formatTools.dart';

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
  String bandShortName;
  String bandLongName;

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
    this.bandShortName,
    this.bandLongName,
  });
}

class Section {
  String name;
  String id;

  Section({
    this.name,
    this.id,
  });
}

class GigInfo {
  String gigStatus;
  String gigBand;
  String gigContact;
  String rawDate;
  String gigDate;
  String gigCallTime;
  String gigSetTime;
  String gigEndTime;
  String gigAddress;
  String gigAddressLink;
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
      this.gigAddressLink,
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
        gigDate: cleanDate(json["date"]),
        gigCallTime: json["calltime"],
        gigSetTime: json["settime"],
        gigEndTime: json["endtime"],
        gigAddress: json["address"],
        gigAddressLink: googleMapsAdd(json["address"]),
        gigPaid: json["paid"],
        gigLeader: json["leader"],
        gigPostGig: json["postgig"],
        gigDetails: json["details"],
        gigTitle: json["title"],
        gigSetList: json["setlist"]);
  }
}

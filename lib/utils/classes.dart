//Class definitions here
import 'formatTools.dart';

class Gig {
  String? title;
  String? date;
  String? gig_status;
  // String? planValue;
  // String? planValueLabel;
  // String? planComment;
  // String? planID;
  String? id;
  // String? bandID;
  // String? bandShortName;
  String? band;

  Gig({
    this.title,
    this.date,
    this.gig_status,
    // this.planValue,
    // this.planValueLabel,
    // this.planComment,
    // this.planID,
    this.id,
    // this.bandID,
    // this.bandShortName,
    this.band,
  });
}

class Section {
  String? name;
  String? id;

  Section({
    this.name,
    this.id,
  });
}

class Band {
  String? name;
  bool? simpleOptions;

  Band({this.name, this.simpleOptions});
}

class GigInfo {
  String? gigStatus;
  String? gigBand;
  String? gigContact;
  String? rawDate;
  String? gigDate;
  String? gigCallTime;
  String? gigSetTime;
  String? gigEndTime;
  String? gigAddress;
  String? gigAddressLink;
  String? gigPaid;
  String? gigLeader;
  String? gigPostGig;
  String? gigDetails;
  String? gigTitle;
  String? gigSetList;

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
        gigDate: json["date"],
        gigCallTime: formatLocalTime(json["call_time"]),
        gigSetTime: formatLocalTime(json["set_time"]),
        gigEndTime: formatLocalTime(json["end_time"]),
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

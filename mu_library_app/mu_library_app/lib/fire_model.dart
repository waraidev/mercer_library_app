//This is the class for the Firebase data

class ApptData {
  DateTime dateTime;
  String loc, muid, name, email, major, specLoc, extraDetails, meetingType;

  ApptData(this.dateTime, this.loc, this.muid, this.name,
      this.email, this.major, this.specLoc, this.extraDetails, this.meetingType);

  toJson() {
    return {
      "datetime": dateTime,
      "location": loc,
      "muid": muid,
      "name": name,
      "email": email,
      "major": major,
      "specloc": specLoc,
      "details": extraDetails,
      "meeting-type": meetingType,
    };
  }
}
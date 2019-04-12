//This is the class for the Firebase data

class ApptData {
  DateTime apptDateTime;
  String apptLoc, apptMUid, apptName,
      apptEmail, apptMajor, apptSpecLoc;

  ApptData(this.apptDateTime, this.apptLoc, this.apptMUid,
      this.apptName, this.apptEmail, this.apptMajor, this.apptSpecLoc);

  toJson() {
    return {
      "datetime": apptDateTime,
      "location": apptLoc,
      "muid": apptMUid,
      "name": apptName,
      "email": apptEmail,
      "major": apptMajor,
      "specloc": apptSpecLoc
    };
  }
}
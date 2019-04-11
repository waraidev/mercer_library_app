//This is the class for the Firebase data

class ApptData {
  String apptDate, apptLoc, apptMUid, apptName, apptTime;

  ApptData(this.apptDate, this.apptLoc, this.apptMUid,
      this.apptName, this.apptTime);

  toJson() {
    return {
      "date": apptDate,
      "location": apptLoc,
      "muid": apptMUid,
      "name": apptName,
      "room": apptRoom,
      "time": apptTime
    };
  }
}
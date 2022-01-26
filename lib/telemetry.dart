class Employee {
  String firstName;
  String lastName;
  String mobileNo;
  String emailId;

  Employee(this.firstName, this.lastName, this.mobileNo, this.emailId);
  Employee.fromMap(Map map) {
    firstName = map[firstName];
    lastName = map[lastName];
    mobileNo = map[mobileNo];
    emailId = map[emailId];
  }
}


class Telemetry {
  final int id;
  final int serial;
  final String filename;
  final int dataPoints;
  final String payload;
  final DateTime downloadDate;
  final DateTime uploadDate;

  Telemetry(
    this.id,
    this.serial,
    this.filename,
    this.dataPoints,
    this.payload,
    this.downloadDate,
    this.uploadDate,
  );

  Telemetry.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        serial = res["serial"],
        filename = res["filename"],
        dataPoints = res["dataPoints"],
        payload = res["payload"],
        downloadDate = res["downloadDate"],
        uploadDate = res["uploadDate"];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serial': serial,
      'filename': filename,
      'dataPoints': dataPoints,
      'payload': payload,
      'downloadDate': downloadDate,
      'uploadDate': uploadDate
    };
  }

}

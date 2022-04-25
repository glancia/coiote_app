

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

  Telemetry.fromMapCat(Map<String, dynamic> res, int serial)
      : id = null,
        serial = serial,
        filename = res["m"]["file"],
        dataPoints = 0,
        payload = res["m"]["payload"],
        downloadDate = DateTime.now(),
        uploadDate = null;

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

class TelemetrySummary {
  final int serial;
  final int files;
  final int dataPoints;

  TelemetrySummary(
      this.serial,
      this.files,
      this.dataPoints,
      );

  TelemetrySummary.fromMap(Map<String, dynamic> res)
      : serial = res["serial"],
        files = res["files"],
        dataPoints = res["dataPoints"];

  Map<String, dynamic> toMap() {
    return {
      'serial': serial,
      'files': files,
      'dataPoints': dataPoints
    };
  }
}

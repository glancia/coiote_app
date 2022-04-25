import 'package:flutter/material.dart';
import 'package:flutter_blue_example/BLE.dart';
import 'package:flutter_blue_example/formatters.dart';
import 'package:flutter_blue_example/main.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:inspection/inspection.dart';
import 'dart:math';
import 'package:flutter_blue_example/db.dart';
import 'package:flutter_blue_example/telemetry.dart';
import 'package:flutter_blue_example/filelist.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void _putData() {
  int id;
  int serial = 40002;
  String filename = "/sd/db/40002_20220417.t";
  int dataPoints = 5;
  String payload = '{"m": {"error": "", "file": "/sd/db/40002_20220417.t", "payload": "9224874;1;7;896;896;0;32\n"}, "t": "cat"}';
  DateTime downloadDate = DateTime.now();
  DateTime uploadDate;
  var dbHelper = DBHelper();
  var telemetry = Telemetry(id, serial, filename, dataPoints, payload, downloadDate, null);
  dbHelper.saveTelemetry(telemetry);
}


Future<List<TelemetrySummary>> _getData() async {
  var dbHelper = DBHelper();
  List<TelemetrySummary> summary = await dbHelper.getTelemetrySummary();
  return summary;
}

Future<bool> uploadFile(Telemetry telemetry) async {
  var dbHelper = DBHelper();
  var body = {
    "sn": telemetry.serial,
    "type": "telemetry",
    "payload": telemetry.payload
  };
  var r = await http.post(
    Uri.parse('https://solarhub.engecomp.io/coiote/p1l0t'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'token': '1740800',
      'accept': 'application/json'
    },
    body: jsonEncode(body),
  );
  if (r.statusCode == 200) {
    DBHelper().markUploaded(telemetry);
  }
  return true;
}


class UlScreen extends StatefulWidget {
  // const WifiScreen({Key? key}) : super(key: key);

  @override
  State<UlScreen> createState() => _UlScreenState();
}

class _UlScreenState extends State<UlScreen> {

  Future<List<TelemetrySummary>> _calculation = _getData();
  bool dirty = false;
  double _progress = 0;
  bool _uploading = false;
  List<Future> futures = [];

  @override
  void initState() {
    super.initState();
  }

  Future _sendData() async {
    var processedFiles = 0;

    setState(() { _uploading = true; });

    var dbHelper = DBHelper();
    List<Telemetry> files = await dbHelper.getTelemetry();
    var totalFiles = files.length;

    files.forEach((file) {
      futures.add(
        uploadFile(file).then((value) {
          processedFiles++;
          setState(() {_progress = processedFiles/totalFiles;});
        })
      );
    });

    await Future.wait(futures);

    setState(() {
      _uploading = false;
      _calculation = _getData();
    });
  }

  Widget ulMain(snapshot) {
    return Expanded(
        child: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                    spacing: 0,
                    runSpacing: 10,
                    children: [
                      ulHeader(snapshot),
                      bodyFields(snapshot),
                    ]
                )
            )));
  }

  Widget ulHeader(snapshot) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Enviar dados", textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ]);
  }

  List<DataRow> telemetrySummaryRows(snapshot) {
    List<DataRow> dataRows = [];
    snapshot.data.forEach((TelemetrySummary telemetry) => {
      dataRows.add(
        DataRow(
            cells: <DataCell>[
        DataCell(Text(telemetry.serial.toString())),
        DataCell(Text(telemetry.files.toString())),
        DataCell(Text(telemetry.dataPoints.toString())),
        ],
      )
      )
    });
    return dataRows;
  }

  Widget bodyFields(snapshot) {
    return Wrap(
        spacing: 20, // to apply margin in the main axis of the wrap
        runSpacing: 20,
        children: [
          Offstage(
            offstage: !_uploading,
            child: Column(
                children: [
                  Text("Aguarde..."),
                  LinearProgressIndicator(
                    value: _progress,
                  ),
                ]
            ),
          ),
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Remota',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Arquivos',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Datapoints',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows: telemetrySummaryRows(snapshot),
              ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: snapshot.data.length > 0
                  ? () {
                      _sendData();
                    }
                  : null,
              child: Text('Enviar'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     _putData();
            //   },
            //   child: Text('Novo dado'),
            // )
          ])
        ]);
  }

  Widget futureBuilder() {
    return new FutureBuilder<List<TelemetrySummary>>(
      future: _calculation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<TelemetrySummary>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            ulMain(snapshot)
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Aguarde...'),
            )
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => {
              setState(() { _calculation = _getData(); })
            },
          ),
        ],
      ),
      body: futureBuilder(),
    );
  }
}

//
// class UploadData extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//             title: Text('Enviar dados para nuvem'),
//             centerTitle: true,
//             backgroundColor: Colors.white,
//             leading: InkWell(
//                 onTap: () {Navigator.pop(context);},
//                 child: Icon(Icons.arrow_back))
//         ),
//         body: Container(
//             constraints: BoxConstraints(maxWidth: 300, maxHeight: 500),
//             padding: const EdgeInsets.all(10.0),
//             child: Column(children: [
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.refresh, size: 18),
//                 label: Text('Atualizar'),
//                 onPressed: () {},
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.refresh, size: 18),
//                 label: Text('criar'),
//                 onPressed: () {
//                   return _putData();
//                 },
//               ),
//               Container(
//                   constraints: BoxConstraints(maxWidth: 300, maxHeight: 500),
//                   child: MyEmployeeList())
//             ])));
//   }
//
// }

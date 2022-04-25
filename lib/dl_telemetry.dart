import 'package:flutter/material.dart';
import 'package:flutter_blue_example/BLE.dart';
import 'package:flutter_blue_example/formatters.dart';
import 'package:flutter_blue_example/main.dart';
import 'package:flutter_blue_example/db.dart';
import 'package:flutter_blue_example/telemetry.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:inspection/inspection.dart';

Future<Map> _getData() async {
  return await sendBleCommand('list telemetry');
}

class DlScreen extends StatefulWidget {
  // const WifiScreen({Key? key}) : super(key: key);

  @override
  State<DlScreen> createState() => _DlScreenState();
}

class _DlScreenState extends State<DlScreen> {

  Future<Map> _calculation = _getData();
  bool dirty = false;
  bool _downloading = false;
  double _progress = 0;
  List<Map> files = [];
  Map telemetry = {};
  int totalFiles = 0;

  void _putData(Map data, int serial) {
    Telemetry telemetry = Telemetry.fromMapCat(data, serial);
    var dbHelper = DBHelper();
    dbHelper.saveTelemetry(telemetry);
  }

  void download(snapshot) async {
    int pageFiles = snapshot.data["m"]["count"];
    int initialTotalFiles = totalFiles;
    int downloadedFiles = 0;
    int serial;
    Map newQuery;

    _progress = 0;

    setState(() {
      _downloading = true;
    });
    files = snapshot.data["m"]["files"];
    while (totalFiles > 0) {
      for(var file in files ) {
        telemetry = await sendBleCommand('cat ${file["n"]}');
        if (telemetry["m"]["error"] == "") {
          serial = int.parse(telemetry["m"]["sn"]);
          _putData(telemetry, serial);
        }

        dirty = true;
        totalFiles--;
        print("Total files: $totalFiles");
        downloadedFiles++;
        setState(() {
          _progress = downloadedFiles / initialTotalFiles;
        });
      }
      if (totalFiles > 0) {
        newQuery = await sendBleCommand('list telemetry');
        totalFiles = newQuery["m"]["count"];
        files = newQuery["m"]["files"];
      }
    }
    setState(() {
      _downloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget dlMain(snapshot) {
    return Expanded(
        child: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                    spacing: 0,
                    runSpacing: 10,
                    children: [
                      dlHeader(snapshot),
                      bodyFields(snapshot),
                    ]
                )
            )));
  }

  Widget dlHeader(snapshot) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Baixar arquivos da remota", textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)),

        ]);
  }

  Widget bodyFields(snapshot) {
    return Wrap(
        spacing: 20, // to apply margin in the main axis of the wrap
        runSpacing: 20,
        children: [
          Text("Total: $totalFiles arquivos"),
          Offstage(
            offstage: !_downloading,
            child: Column(
            children: [
              Text("Aguarde..."),
              LinearProgressIndicator(
              value: _progress,
            ),
            ]
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: (totalFiles <= 0 || _downloading)  ? null :
                  () { download(snapshot); },
              child: Text('Baixar'),
            )
          ])
        ]);
  }

  Widget futureBuilder() {
    return new FutureBuilder<Map>(
      future: _calculation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          totalFiles = dirty ? totalFiles : snapshot.data["m"]["total"];
          children = <Widget>[
            dlMain(snapshot)
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

      ),
      body: futureBuilder(),
    );
  }
}
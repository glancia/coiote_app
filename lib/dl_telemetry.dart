import 'package:flutter/material.dart';
import 'package:flutter_blue_example/BLE.dart';
import 'package:flutter_blue_example/formatters.dart';
import 'package:flutter_blue_example/main.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:inspection/inspection.dart';
import 'dart:math';

aleat() {
  var rng = Random();
  return rng.nextInt(100);
}

Future<Map> _getData() async {
  // return await sendBleCommand('list telemetry');
  return await new Future<Map>.delayed(
    const Duration(seconds: 2),
        () =>        {"m":{"files":[{"t":1650202200,"d":0,"s":577,"n":"/sd/db/20220417133000_1.json"},{"t":1650202201,"d":0,"s":573,"n":"/sd/db/20220417133001_2.json"}],"count":10,"total":10},"t":"ls"},
  );

}

class DlScreen extends StatefulWidget {
  // const WifiScreen({Key? key}) : super(key: key);

  @override
  State<DlScreen> createState() => _DlScreenState();
}

class _DlScreenState extends State<DlScreen> {

  Future<Map> _calculation = _getData();
  bool dirty = false;
  bool _passwordVisible = false;
  bool _downloading = false;
  double progress = 0;

  void download(snapshot) async {
    int totalFiles = snapshot.data["m"]["total"];
    int pageFiles = snapshot.data["m"]["count"];
    int initialTotalFiles = totalFiles;
    int downloadedFiles = 0;
    setState(() {
      _downloading = true;
    });
    for (var i = pageFiles; i > 0; i--) {
      await new Future.delayed(const Duration(milliseconds : 1000));
      totalFiles--;
      downloadedFiles++;
      setState(() {
        progress = downloadedFiles/initialTotalFiles;
        snapshot.data["m"]["total"] = totalFiles;
      });
    }
    setState(() {
      _downloading = true;
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
          Text("Total: ${snapshot.data["m"]["total"]} arquivos"),
          Offstage(
            offstage: !_downloading,
            child: LinearProgressIndicator(
              value: progress,
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: (snapshot.data["m"]["total"] <= 0)  ? null :
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
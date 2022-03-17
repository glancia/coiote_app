// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_blue_example/dbhelper.dart';
import 'package:flutter_blue_example/telemetry.dart';
import 'package:flutter_blue_example/filelist.dart';
import 'package:flutter_blue_example/BLE.dart';
import 'dart:convert';

void main() {

  runApp(CoioteApp());
}


void _putData() {
  int id;
  int serial = 40010;
  String filename = "40010_2201051515.t";
  int dataPoints = 5;
  String payload = "2201051515;5;5;1;1;1;1";
  DateTime downloadDate = DateTime.now();
  DateTime uploadDate = DateTime.now();
  var dbHelper = DBHelper();
  var telemetry = Telemetry(id, serial, filename, dataPoints, payload, downloadDate, uploadDate);
  dbHelper.saveTelemetry(telemetry);
}

class CoioteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(fontFamily: 'BankGothic'),
        home: new Home());
  }
}


class Home extends StatelessWidget {
  double textSize = 18;
  double iconSize = 40;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          leading: Container(
            child: Teste(),
          ),
          title: Text("Engecomp CoIoTe"),
          centerTitle: true,
        ),
        body: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          children: [
            Material(child: InkWell(
                onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => FlutterBlueApp()),);},
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.bluetooth, size: iconSize),
                  Text('Bluetooth', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => StatusScreen()),);},
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.perm_device_info, size: iconSize),
                  Text('Status', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {
                  print('2 was clicked');
                },
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.wifi, size: iconSize),
                  Text('WiFi', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {
                  print('2 was clicked');
                },
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.flash_on, size: iconSize),
                  Text('Saída de Usuário', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {
                  print('2 was clicked');
                },
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.settings_ethernet, size: iconSize),
                  Text('Ethernet', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => UploadData()),);},
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.cloud_upload_outlined, size: iconSize),
                  Text('Enviar Dados', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {
                  print('2 was clicked');
                },
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.download_for_offline, size: iconSize),
                  Text('Extrair Dados da Remota', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {
                  print('2 was clicked');
                },
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.swap_horizontal_circle_outlined, size: iconSize),
                  Text('Modbus', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            )

          ],
        ),
      );
  }
}

// class UploadData extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         children: [
//           Align(
//             alignment: Alignment.topCenter,
//             child: Text('Enviar dados para nuvem'),
//           )
//         ]
//             title: Text('Enviar dados para nuvem'),
//             centerTitle: true,
//             backgroundColor: Colors.white,
//             leading: InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
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
// }

class UploadData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Enviar dados para nuvem'),
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: InkWell(
                onTap: () {Navigator.pop(context);},
                child: Icon(Icons.arrow_back))
        ),
        body: Container(
        constraints: BoxConstraints(maxWidth: 300, maxHeight: 500),
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('Atualizar'),
            onPressed: () {},
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('criar'),
            onPressed: () {
              return _putData();
            },
          ),
          Container(
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 500),
              child: MyEmployeeList())
        ])));
  }

}

// class Home extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           leadingWidth: 100,
//           leading: Container(
//             //child: Row(children: [Icon(Icons.bluetooth_disabled), Text("40001")]),
//             child: Teste(),
//           ),
//           title: Text("Engecomp CoIoTe"),
//           centerTitle: true,
//           bottom: TabBar(
//             tabs: [
//               Tab(icon: Icon(Icons.home)),
//               Tab(icon: Icon(Icons.flash_on)),
//               Tab(icon: Icon(Icons.table_rows_rounded)),
//               Tab(icon: Icon(Icons.bluetooth)),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             StatusScreen(),
//             Icon(Icons.directions_transit),
//             Container(
//                 constraints: BoxConstraints(maxWidth: 300, maxHeight: 500),
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(children: [
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
//             ])),
//             // MyApp(),
//             FlutterBlueApp(),
//           ],
//         ),
//       ),
//     ));
//   }
// }


class StatusScreen extends StatefulWidget {
  static String id = 'home_screen';

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Map eventList = {};

  @override
  void initState() {
    super.initState();
    // sendBleCommand('get status');
    getStatusScreen();
  }

  Future<Null> getStatusScreen() async {

    eventList = {};
    setState(() {});

    eventList = await sendBleCommand('get status');
    String x = jsonEncode(eventList);
    print("Widget: "+x);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => getStatusScreen(),
          ),
        ],
      ),
      body: Column(
          children: <Widget>[
            buildEventList(context),
          ]
      ),);

  }


  Widget buildEventList(BuildContext context) {
    return Expanded(
        child: Container(
          child: (eventList == null || eventList.length == 0)
              ? Center(child: CircularProgressIndicator()) :

          Center(child:
              Column(children: [
                Text(eventList["m"]["system"]["sn"].toString()),
                Text(eventList["m"]["system"]["bios_version"].toString()),
                Text(eventList["m"]["system"]["time"].toString()),
                Text(eventList["m"]["system"]["uptime"].toString()),
                Text(eventList["m"]["wlan"]["name"].toString()),
                Text(eventList["m"]["wlan"]["ip"].toString()),

          ]
          ))
        ));
  }

}
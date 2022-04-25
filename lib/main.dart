// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_blue_example/db.dart';
import 'package:flutter_blue_example/telemetry.dart';
import 'package:flutter_blue_example/filelist.dart';
import 'package:flutter_blue_example/BLE.dart';
import 'package:flutter_blue_example/Eth.dart';
import 'package:flutter_blue_example/wifi.dart';
import 'package:flutter_blue_example/dl_telemetry.dart';
import 'package:flutter_blue_example/ul_telemetry.dart';
// import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:inspection/inspection.dart';

void main() {
  runApp(CoioteApp());
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
                onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => WifiScreen()));},
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
                onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => EthScreen()),);},
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.settings_ethernet, size: iconSize),
                  Text('Ethernet', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => UlScreen()),);},
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.cloud_upload_outlined, size: iconSize),
                  Text('Enviar Dados', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(child: InkWell(
                onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => DlScreen()),);},
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.download_for_offline, size: iconSize),
                  Text('Extrair Dados da Remota', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize) )
                ])),
            ),
            Material(
              child: InkWell(
                onTap: null,
                //     () {
                //   print('2 was clicked');
                // },
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  Icon(Icons.swap_horizontal_circle_outlined, size: iconSize, color: Colors.grey,),
                  Text('Modbus', textAlign: TextAlign.center, style: TextStyle(fontSize: textSize, color: Colors.grey) )
                ])),
            )

          ],
        ),
      );
  }
}


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
    getStatusScreen();
  }

  Future<Null> getStatusScreen() async {

    eventList = {};
    setState(() {});

    eventList = await sendBleCommand('get status');

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
            padding: const EdgeInsets.all(20),
            child: (eventList == null || eventList.length == 0)
                ? Center(child: CircularProgressIndicator())
                : GridView
                    .count(crossAxisCount: 1, crossAxisSpacing: 20, childAspectRatio: 2, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                        children: [
                      Text("Status", textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NS"),
                              Text("BIOS"),
                              Text("Relógio"),
                              Text("Temp. Interna"),
                              Text("Uptime"),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(eventList["m"]["system"]["sn"].toString()),
                              Text(eventList["m"]["system"]["bios_version"]
                                  .toString()),
                              Text(eventList["m"]["system"]["time"].toString()),
                              Text(eventList["m"]["temperature"].toString()),
                              Text(
                                  eventList["m"]["system"]["uptime"].toString())
                            ])
                      ])
                    ]),



              Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ethernet", textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nome"),
                                Text("IP"),
                                Text("Mask"),
                                Text("Gateway"),
                                Text("DNS"),
                                Text("MAC"),
                                Text("Sinal"),
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(eventList["m"]["eth0"]["name"].toString()),
                                Text(eventList["m"]["eth0"]["ip"].toString()),
                                Text(eventList["m"]["eth0"]["mask"].toString()),
                                Text(eventList["m"]["eth0"]["gateway"].toString()),
                                Text(eventList["m"]["eth0"]["dns"].toString()),
                                Text(eventList["m"]["eth0"]["mac"].toString()),
                                Text(eventList["m"]["eth0"]["signal"].toString())
                              ])
                        ])
                  ]),

              Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Wifi", textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nome"),
                                Text("IP"),
                                Text("Mask"),
                                Text("Gateway"),
                                Text("DNS"),
                                Text("MAC"),
                                Text("Sinal"),
                              ]),

                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(eventList["m"]["wlan"]["name"].toString()),
                                Text(eventList["m"]["wlan"]["ip"].toString()),
                                Text(eventList["m"]["wlan"]["mask"].toString()),
                                Text(eventList["m"]["wlan"]["gateway"].toString()),
                                Text(eventList["m"]["wlan"]["dns"].toString()),
                                Text(eventList["m"]["wlan"]["mac"].toString()),
                                Text(eventList["m"]["wlan"]["signal"].toString())
                              ])
                        ])
                  ]),


                  ])));
  }
}




import 'package:flutter/material.dart';
import 'package:flutter_blue_example/formatters.dart';
import 'package:flutter_blue_example/BLE.dart';

class EthScreen extends StatefulWidget {
  static String id = 'eth_screen';

  @override
  _EthScreenState createState() => _EthScreenState();
}

class _EthScreenState extends State<EthScreen> {
  Map eventList = {};
  bool dirty = false;
  bool enabled = false;
  int dhcp = -1;
  String ip = "";
  String mask = "";
  String gateway = "";
  String dns = "";

  @override
  void initState() {
    super.initState();
    getEthScreen();
  }

  Future<Null> getEthScreen() async {
    eventList = await sendBleCommand('get config');

    dhcp = eventList["m"]["networks"]["eth0"]["mode"] == "dhcp" ? 1 : 0;
    enabled = eventList["m"]["networks"]["eth0"]["enabled"];
    eventList = await sendBleCommand('get config');
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => getEthScreen(),
          ),
        ],
      ),
      body:
      Column(
          children: <Widget>[
            buildEventList(context),
          ]
      ),);

  }

  Widget buildEventList(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(15),
                child: (eventList == null || eventList.length == 0)
                    ? Center(child: CircularProgressIndicator())
                    :
                Wrap(
                    spacing: 0,
                    runSpacing: 10,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ethernet", textScaleFactor: 1.5,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Switch(
                              value: enabled,
                              onChanged: (value) {
                                setState(() {
                                  enabled = value;
                                  dirty = true;
                                });
                                sendBleCommand("eth ${value ? 'on' : 'off'}");
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                            ),
                          ]),

                      Row(mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("DHCP", textScaleFactor: 1.2),
                            Radio(
                              value: 1,
                              groupValue: dhcp,
                              onChanged: (value) {
                                setState(() {
                                  dhcp = value;
                                  dirty = true;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            Text("IP Fixo", textScaleFactor: 1.2),
                            Radio(
                              value: 0,
                              groupValue: dhcp,
                              onChanged: (value) {
                                setState(() {
                                  dhcp = value;
                                  dirty = true;
                                });
                              },
                              activeColor: Colors.green,
                            )
                          ]),
                      Offstage(
                          offstage: (dhcp == 1),
                          child: Wrap(
                              spacing: 0,
                              runSpacing: 10,
                              children: [
                                TextField(
                                  inputFormatters: [ipFormatter],
                                  decoration: InputDecoration(
                                    labelText: "IP",
                                    border: OutlineInputBorder(),
                                    hintText: '___.___.___.___',
                                  ),
                                  onChanged: (text) {
                                    print('First text field: $text');
                                    ip = text;
                                    dirty = true;
                                  },
                                ),
                                TextFormField(
                                  initialValue: eventList["m"]["networks"]["eth0"]["rt"]["mask"],
                                  inputFormatters: [ipFormatter],
                                  decoration: InputDecoration(
                                    labelText: "Mask",
                                    border: OutlineInputBorder(),
                                    hintText: '___.___.___.___',
                                  ),
                                  onChanged: (text) {
                                    print('First text field: $text');
                                    mask = text;
                                    dirty = true;
                                  },
                                ),
                                TextField(
                                  inputFormatters: [ipFormatter],
                                  decoration: InputDecoration(
                                    labelText: "Gateway",
                                    border: OutlineInputBorder(),
                                    hintText: '___.___.___.___',
                                  ),
                                  onChanged: (text) {
                                    print('First text field: $text');
                                    gateway = text;
                                    dirty = true;
                                  },
                                ),
                                TextField(
                                  inputFormatters: [ipFormatter],
                                  decoration: InputDecoration(
                                    labelText: "DNS",
                                    border: OutlineInputBorder(),
                                    hintText: '___.___.___.___',
                                  ),
                                  onChanged: (text) {
                                    print('First text field: $text');
                                    dns = text;
                                    dirty = true;
                                  },
                                ),])),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [ElevatedButton(
                            onPressed: dirty ?
                                () {
                              if (dhcp == 1) {
                                sendBleCommand("eth dhcp");
                              } else {
                                sendBleCommand("eth static $ip $mask $gateway $dns");
                              }
                            }
                                : null,
                            child: Text('Salvar'),
                          )])

                    ])
            )));

  }
}

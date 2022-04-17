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

    eventList = {
      "m":
      {
        "token": "",
        "gpio":
        {
          "led":
          {
            "pin": 0,
            "on_state": 0
          },
          "eth":
          {
            "phy_type": "LAN8720",
            "reset": 0,
            "mdc": 8,
            "mdio": 7,
            "phy_address": 0
          }
        },
        "serial_ports":
        {
          "port2":
          {
            "name": "/dev/ttyUSB2",
            "databits": 8,
            "parity": "N",
            "stopbits": 1,
            "pins":
            {
              "reset": 0,
              "rx": 35,
              "cts": 0,
              "power": 0,
              "rts": 0,
              "tx": 20
            },
            "baudrate": 115200
          },
          "port0":
          {
            "name": "/dev/ttyUSB0",
            "databits": 8,
            "parity": "N",
            "stopbits": 1,
            "pins":
            {
              "reset": 0,
              "rx": 0,
              "cts": 0,
              "power": 0,
              "rts": 0,
              "tx": 0
            },
            "baudrate": 115200
          },
          "port1":
          {
            "name": "/dev/ttyUSB1",
            "databits": 8,
            "parity": "N",
            "stopbits": 1,
            "pins":
            {
              "reset": 0,
              "rx": 5,
              "cts": 0,
              "power": 0,
              "rts": 0,
              "tx": 2
            },
            "baudrate": 115200
          }
        },
        "networks":
        {
          "wifi":
          {
            "mode": "sta",
            "pwd": "tigertid",
            "enabled": true,
            "ssid": "BGML",
            "rt":
            {
              "mac": "",
              "ip": "",
              "mask": "",
              "gateway": "",
              "dns": ""
            }
          },
          "eth0":
          {
            "rt":
            {
              "mac": "",
              "ip": "192.168.9.0",
              "mask": "255.255.255.0",
              "gateway": "192.168.0.1",
              "dns": "8.8.8.8"
            },
            "enabled": false,
            "mode": "dhcp"
          },
          "ppp":
          {
            "apn": "",
            "rt":
            {
              "mac": "",
              "ip": "",
              "mask": "",
              "gateway": "",
              "dns": ""
            },
            "enabled": true,
            "usr": "",
            "operator": "",
            "pin": "",
            "verbose": true
          }
        },
        "applications":
        {}
      }
    };

    dhcp = eventList["m"]["networks"]["eth0"]["mode"] == "dhcp" ? 1 : 0;
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
                              value: eventList["m"]["networks"]["eth0"]["enabled"],
                              onChanged: (value) {
                                setState(() {
                                  eventList["m"]["networks"]["eth0"]["enabled"] =
                                      value;
                                  dirty = true;
                                });
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
                                TextField(
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
                                print("eth dhcp");
                              } else {
                                print("eth static $ip $mask $gateway $dns");
                              }
                            }
                                : null,
                            child: Text('Salvar'),
                          )])

                    ])
            )));

  }
}

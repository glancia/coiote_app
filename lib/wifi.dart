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
  // return await sendBleCommand('get config');
  return await new Future<Map>.delayed(
    const Duration(seconds: 2),
        () =>        {
      "m":
      {
        "token": aleat(),
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
    },
  );

}




class WifiScreen extends StatefulWidget {
  // const WifiScreen({Key? key}) : super(key: key);

  @override
  State<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {

  Future<Map> _calculation = _getData();
  bool dirty = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget wifiMain(snapshot) {
    return Expanded(
        child: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                    spacing: 0,
                    runSpacing: 10,
                    children: [
                      wifiHeader(snapshot),
                      bodyFields(snapshot),
                    ]
                )
            )));
  }

  Widget wifiHeader(snapshot) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Wifi", textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)),
          Switch(
            value: snapshot.data["m"]["networks"]["wifi"]["enabled"],
            onChanged: (value) {
              setState(() async {
                snapshot.data["m"]["networks"]["wifi"]["enabled"] = value;
                await sendBleCommand("wifi ${value ? 'on' : 'off'}");
              // dirty = true;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ]);
  }

  Widget bodyFields(snapshot) {
    return Wrap(
        spacing: 20, // to apply margin in the main axis of the wrap
        runSpacing: 20,
        children: [
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Station", textScaleFactor: 1.2),
                Radio(
                  value: 'sta',
                  groupValue: snapshot.data["m"]["networks"]["wifi"]["mode"],
                  onChanged: (value) {
                    setState(() {
                      snapshot.data["m"]["networks"]["wifi"]["mode"] = value;
                      dirty = true;
                    });
                  },
                  activeColor: Colors.green,
                ),
                Text("Access Point", textScaleFactor: 1.2),
                Radio(
                  value: 'ap',
                  groupValue: snapshot.data["m"]["networks"]["wifi"]["mode"],
                  onChanged: (value) {
                    setState(() {
                      snapshot.data["m"]["networks"]["wifi"]["mode"] = value;
                      dirty = true;
                    });
                  },
                  activeColor: Colors.green,
                )
              ]),
          TextFormField(
            initialValue: snapshot.data["m"]["networks"]["wifi"]["ssid"],
            inputFormatters: [ipFormatter],
            decoration: InputDecoration(
                labelText: "SSID", border: OutlineInputBorder()),
            onChanged: (text) {
              snapshot.data["m"]["networks"]["wifi"]["ssid"] = text;
              dirty = true;
            },
          ),
          TextFormField(
            initialValue: snapshot.data["m"]["networks"]["wifi"]["pwd"],
            inputFormatters: [ipFormatter],
            obscureText: !_passwordVisible,//This will obscure text dynamically
            decoration: InputDecoration(
              labelText: "Senha",
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  // Update the state i.e. toggle the state of passwordVisible variable
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            onChanged: (text) {
              print('First text field: $text');
              snapshot.data["m"]["networks"]["wifi"]["pwd"] = text;
              dirty = true;
            },
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: dirty
                  ? () {
                      if (1 == 1) {
                        // print("eth dhcp");
                      } else {
                        // print("eth static $ip $mask $gateway $dns");
                      }
                    }
                  : null,
              child: Text('Salvar'),
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
            wifiMain(snapshot)
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







// class WifiScreen extends StatefulWidget {
//   static String id = 'wifi_screen';
//
//   // @override
//   // _WifiScreenState createState() => _WifiScreenState();
// }

// class _WifiScreenState extends State<WifiScreen> {
//   Map eventList = {};
//   bool dirty = false;
//   int dhcp = -1;
//   String SSID = "";
//   String password = "";
//
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   getWifiScreen();
//   // }
//
//   Future<Map> getWifiScreen =  Future<Map>.delayed(
//     const Duration(seconds: 1),  () =>
//       {
//         "m":
//         {
//           "token": "",
//           "gpio":
//           {
//             "led":
//             {
//               "pin": 0,
//               "on_state": 0
//             },
//             "eth":
//             {
//               "phy_type": "LAN8720",
//               "reset": 0,
//               "mdc": 8,
//               "mdio": 7,
//               "phy_address": 0
//             }
//           },
//           "serial_ports":
//           {
//             "port2":
//             {
//               "name": "/dev/ttyUSB2",
//               "databits": 8,
//               "parity": "N",
//               "stopbits": 1,
//               "pins":
//               {
//                 "reset": 0,
//                 "rx": 35,
//                 "cts": 0,
//                 "power": 0,
//                 "rts": 0,
//                 "tx": 20
//               },
//               "baudrate": 115200
//             },
//             "port0":
//             {
//               "name": "/dev/ttyUSB0",
//               "databits": 8,
//               "parity": "N",
//               "stopbits": 1,
//               "pins":
//               {
//                 "reset": 0,
//                 "rx": 0,
//                 "cts": 0,
//                 "power": 0,
//                 "rts": 0,
//                 "tx": 0
//               },
//               "baudrate": 115200
//             },
//             "port1":
//             {
//               "name": "/dev/ttyUSB1",
//               "databits": 8,
//               "parity": "N",
//               "stopbits": 1,
//               "pins":
//               {
//                 "reset": 0,
//                 "rx": 5,
//                 "cts": 0,
//                 "power": 0,
//                 "rts": 0,
//                 "tx": 2
//               },
//               "baudrate": 115200
//             }
//           },
//           "networks":
//           {
//             "wifi":
//             {
//               "mode": "sta",
//               "pwd": "tigertid",
//               "enabled": true,
//               "ssid": "BGML",
//               "rt":
//               {
//                 "mac": "",
//                 "ip": "",
//                 "mask": "",
//                 "gateway": "",
//                 "dns": ""
//               }
//             },
//             "eth0":
//             {
//               "rt":
//               {
//                 "mac": "",
//                 "ip": "192.168.9.0",
//                 "mask": "255.255.255.0",
//                 "gateway": "192.168.0.1",
//                 "dns": "8.8.8.8"
//               },
//               "enabled": false,
//               "mode": "dhcp"
//             },
//             "ppp":
//             {
//               "apn": "",
//               "rt":
//               {
//                 "mac": "",
//                 "ip": "",
//                 "mask": "",
//                 "gateway": "",
//                 "dns": ""
//               },
//               "enabled": true,
//               "usr": "",
//               "operator": "",
//               "pin": "",
//               "verbose": true
//             }
//           },
//           "applications":
//           {}
//         }
//       }
//
//
//   );
//
//
//
//     // dhcp = eventList["m"]["networks"]["eth0"]["mode"] == "dhcp" ? 1 : 0;
//     // setState(() {});
//
//     // return eventList
//
//     //eventList = await sendBleCommand('get config');
//
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.refresh),
//             //onPressed: () => getWifiScreen(),
//             onPressed: () => '',
//           ),
//         ],
//       ),
//       body: FutureBuilder<Null> (
//         future: getWifiScreen,
//         builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//             List<Widget> children;
//             if (snapshot.hasData) {
//               children = [buildEventList(context, snapshot)];
//             } else {
//                 children = const <Widget>[
//                 SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: CircularProgressIndicator(),
//                 )];
//             }
//
//             return Column(
//                 children: children
//             );
//     }));
//   }
//
//   Widget buildEventList(BuildContext context, snapshot) {
//     return Expanded(
//         child: SingleChildScrollView(
//             child: Container(
//                 padding: const EdgeInsets.all(15),
//                 child:
//                 Wrap(
//                     spacing: 0,
//                     runSpacing: 10,
//                     children: [
//                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Wifi", textScaleFactor: 1.5,
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             Switch(
//                               value: snapshot.data["m"]["networks"]["wlan0"]["enabled"],
//                               onChanged: (value) {
//                                 //setState(() {
//                                   snapshot.data["m"]["networks"]["wlan0"]["enabled"] =
//                                       value;
//                                   //dirty = true;
//                                 });
//                               },
//                               activeTrackColor: Colors.lightGreenAccent,
//                               activeColor: Colors.green,
//                             ),
//                           ]),
//
//                       Row(mainAxisSize: MainAxisSize.max,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Station", textScaleFactor: 1.2),
//                             Radio(
//                               value: 1,
//                               groupValue: dhcp,
//                               onChanged: (value) {
//                                 //setState(() {
//                                   dhcp = value;
//                                   dirty = true;
//                                 //});
//                               },
//                               activeColor: Colors.green,
//                             ),
//                             Text("Access Point", textScaleFactor: 1.2),
//                             Radio(
//                               value: 0,
//                               groupValue: dhcp,
//                               onChanged: (value) {
//                                 //setState(() {
//                                   dhcp = value;
//                                   dirty = true;
//                                 //});
//                               },
//                               activeColor: Colors.green,
//                             )
//                           ]),
//                       Offstage(
//                           offstage: (dhcp == 1),
//                           child: Wrap(
//                               spacing: 0,
//                               runSpacing: 10,
//                               children: [
//                                 TextField(
//                                   inputFormatters: [ipFormatter],
//                                   decoration: InputDecoration(
//                                       labelText: "SSID",
//                                       border: OutlineInputBorder()
//                                   ),
//                                   onChanged: (text) {
//                                     SSID = text;
//                                     dirty = true;
//                                   },
//                                 ),
//                                 TextField(
//                                   inputFormatters: [ipFormatter],
//                                   decoration: InputDecoration(
//                                       labelText: "Senha",
//                                       border: OutlineInputBorder()
//                                   ),
//                                   onChanged: (text) {
//                                     print('First text field: $text');
//                                     password = text;
//                                     dirty = true;
//                                   },
//                                 ),
//
//                               ])),
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [ElevatedButton(
//                             onPressed: dirty ?
//                                 () {
//                               if (dhcp == 1) {
//                                 // print("eth dhcp");
//                               } else {
//                                 // print("eth static $ip $mask $gateway $dns");
//                               }
//                             }
//                                 : null,
//                             child: Text('Salvar'),
//                           )])
//
//                     ])
//             )));
//
//   }
// }
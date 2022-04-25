import 'package:flutter/material.dart';
import 'package:flutter_blue_example/BLE.dart';
import 'package:flutter_blue_example/formatters.dart';
import 'package:flutter_blue_example/main.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:inspection/inspection.dart';

Future<Map> _getData() async {
  return await sendBleCommand('get config');
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
  bool enabled = true;
  String mode = "";
  String ssid;
  String pwd;

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
                      wifiHeader(),
                      bodyFields(),
                    ]
                )
            )));
  }

  Widget wifiHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Wifi", textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)),
          Switch(
            value: enabled,
            onChanged: (bool value) {
              print("enabled: $enabled, value: $value");
              setState(() {
                enabled = value;
                print("dentro: enabled: $enabled, value: $value");
              });
              print("enabled: $enabled, value: $value");
              sendBleCommand("wifi ${value ? 'on' : 'off'}");
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ]);
  }

  Widget bodyFields() {
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
                  groupValue: mode,
                  onChanged: (value) {
                    setState(() {
                      print("$value; $mode");
                      mode = value;
                      dirty = true;
                    });
                  },
                  activeColor: Colors.green,
                ),
                Text("Access Point", textScaleFactor: 1.2),
                Radio(
                  value: 'ap',
                  groupValue: mode,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      mode = value;
                      dirty = true;
                    });
                  },
                  activeColor: Colors.green,
                )
              ]),
          TextFormField(
            initialValue: ssid,
            decoration: InputDecoration(
                labelText: "SSID", border: OutlineInputBorder()),
            onChanged: (text) {
              setState(() {
                ssid = text;
                dirty = true;
              });
            },
          ),
          TextFormField(
            initialValue: pwd,
            obscureText: !_passwordVisible,//This will obscure text dynamically
            decoration: InputDecoration(
              labelText: "Senha",
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            onChanged: (text) {
              setState(() {
                pwd = text;
                dirty = true;
              });
            },
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: dirty
                  ? () {
                      if (mode == 'sta') {
                        sendBleCommand("wifi sta $ssid $pwd");
                      } else {
                        sendBleCommand("wifi ap");
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
          mode = dirty ? mode : snapshot.data["m"]["networks"]["wifi"]["mode"];
          enabled = dirty ? enabled : snapshot.data["m"]["networks"]["wifi"]["enabled"];
          ssid = dirty ? ssid : snapshot.data["m"]["networks"]["wifi"]["ssid"];
          pwd = dirty ? pwd : snapshot.data["m"]["networks"]["wifi"]["pwd"];
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


// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/debug.dart';
import 'package:intl/intl.dart';

BluetoothCharacteristic writeC;
BluetoothCharacteristic notifyC;
StreamSubscription stateSubscription;

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
        centerTitle: true,
          leading: InkWell(
        onTap: () {Navigator.pop(context);},
        child: Icon(Icons.arrow_back))
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 5)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                    title: Text(d.name),
                    subtitle: Text(d.id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: d.state,
                      initialData: BluetoothDeviceState.disconnected,
                      builder: (c, snapshot) {
                        if (snapshot.data ==
                            BluetoothDeviceState.connected) {
                          return ElevatedButton(
                            child: Text('DISCONNECT'),
                            // onPressed: () => Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             DeviceScreen(device: d))),
                            onPressed: () => d.disconnect(),
                          );
                        }
                        return Text(snapshot.data.toString());
                      },
                    ),
                  ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data.where((r) => r.device.name.toString().toLowerCase().contains('coiote'))
                      .map(
                        (r) => ScanResultTile(
                      result: r,
                      onTap: () => connect(r.device),
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 5)));
          }
        },
      ),
    );
  }
}


class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        child: Text('CONNECT'),
        //color: Colors.black,
        //textColor: Colors.white,
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),

    );
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;

  const CharacteristicTile(
      {Key key,
      this.characteristic,
      this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Characteristic'),
                Text(
                    '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).textTheme.caption.color))
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: Theme.of(context).iconTheme.color.withOpacity(0.5),
                ),
                onPressed: onReadPressed,
              ),
              IconButton(
                icon: Icon(Icons.file_upload,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                onPressed: onWritePressed,
              ),
              IconButton(
                icon: Icon(
                    characteristic.isNotifying
                        ? Icons.sync_disabled
                        : Icons.sync,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                onPressed: onNotificationPressed,
              )
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;

  const DescriptorTile(
      {Key key, this.descriptor, this.onReadPressed, this.onWritePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Descriptor'),
          Text('0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Theme.of(context).textTheme.caption.color))
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key key, @required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subtitle1,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subtitle1.color,
        ),
      ),
    );
  }
}



class Teste extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      child: StreamBuilder<List<BluetoothDevice>>(
          stream: Stream.periodic(Duration(seconds: 3))
              .asyncMap((_) => FlutterBlue.instance.connectedDevices),
          initialData: [],
          builder: (c, snapshot) => Container(
              child: (snapshot.data.length == 0)
                  ? Row(children: [
                      Icon(Icons.bluetooth_disabled, size: 27),
                    ])
                  : Row(children: [
                      Icon(Icons.bluetooth_connected),
                      Text(snapshot.data[0].name
              .substring(snapshot.data[0].name.length - 5))
              ]))));
}

connect(BluetoothDevice device) async {
  await device.connect();
  // ignore: cancel_subscriptions
  stateSubscription = device.state.listen((event) {
    setupDevice(event, device);
  });
}

setupDevice(BluetoothDeviceState state, BluetoothDevice device) async {
  List<BluetoothDevice> devices = await FlutterBlue.instance.connectedDevices;

  if (state == BluetoothDeviceState.connected) {
    await devices[0].requestMtu(131);
    await new Future.delayed(const Duration(milliseconds : 1000));
    print("will read services");
    List<BluetoothService> services = await devices[0].discoverServices();

    services.forEach((service) async {
      List<BluetoothCharacteristic> characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print(c);
        if (c.properties.notify) {
          notifyC = c;
          await c.setNotifyValue(true);
        }
        if (c.properties.write) {
          writeC = c;
          await setClock();
        }
      }
    });
  } else {
    writeC = null;
    notifyC = null;
    stateSubscription.cancel();
  }
}

Future setClock() async {
  var formatter = new DateFormat('y M d H m s');
  final DateTime now = DateTime.now().toUtc();
  var dateStr = formatter.format(now);
  var weekday = now.weekday == 0 ? 6 : now.weekday -1 ;
  await sendBleCommand('set time '+dateStr+' '+weekday.toString());
}


Future<Map> sendBleCommand(command) async {
  String buffer = "";
  String s = "";
  bool good = false;
  bool timeout = false;
  Map payload;
  var listener;
  StreamSubscription subscription;

  if (DEBUG) {
    return await debug(command);
  }

  if (writeC != null) {
    print("sending command "+command);

    var future = new Future.delayed(const Duration(seconds: 3));
    subscription = future.asStream().listen((value) => timeout = true);

    await new Future.delayed(const Duration(milliseconds : 3000));

    listener = notifyC.value.listen((value) {
      s = utf8.decode(value);
      buffer += s;
      try {
        //print("dentro da função: " + buffer);
        payload = jsonDecode(buffer);
        print(buffer);
        listener.cancel();
        good = true;
      } catch (error) {}
    });
    await writeC.write(utf8.encode(command));
  }
  while (!good || !timeout) {
    await new Future.delayed(const Duration(milliseconds : 300));
  }
  if (subscription != null) {subscription.cancel();}
  return good ? payload : {};
}

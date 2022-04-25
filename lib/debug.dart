import 'dart:math';

const DEBUG = true;

aleat() {
  var rng = Random();
  return rng.nextInt(1500);
}

Future<Map> debug(command) async {
  Map response;
  int delay = aleat();
  print("DEBUG: command: $command - $delay");

  if (command.contains('get config')) {
    response = CONFIG;
  } else if (command.contains('get status')) {
    response = STATUS;
  } else if (command.contains('list telemetry')) {
    response = LIST_TELEMETRY;
  } else if (command.contains('get ssu')) {
    response = SSU;
  } else if (command.contains('cat')) {
    response = CAT;
  }

  print("DEBUG MODE: response will be: $response");
  return await new Future<Map>.delayed(
      Duration(milliseconds: delay),  () => response);
}

const CAT = {"m": {"sn":"40008", "error": "", "file": "/sd/db/40002_20220417.t", "payload": "9224874;1;7;896;896;0;32\n"}, "t": "cat"};
const LIST_TELEMETRY = {"m":{"files":[{"t":1650202200,"d":0,"s":577,"n":"/sd/db/20220417133000_1.json"},{"t":1650202201,"d":0,"s":573,"n":"/sd/db/20220417133001_2.json"}],"count": 2,"total": 2},"t":"ls"};
const STATUS = {"m":{"system":{"sn":40006,"reset":2,"time":"2022-04-23 01:21:28","bios_version":"v1.18-169-g665f0e2","bios_date":"2022-03-03","cc":"0001_0001_01","uptime":5524,"version":"140"},"mqtt":{"reconnections":3,"files_sent":394,"ack_rtt":1445,"ping_rtt":1502,"packets_in":426,"files_errors":0,"bytes_in":69030,"pings_out":4197,"packets_out":584,"bytes_out":540971,"pings_in":4197},"eth0":{"status":5,"mask":"255.255.255.0","name":"dhcp","mac":"30:83:98:d0:9b:7b","ip":"10.0.0.100","gateway":"10.0.0.1","dns":"10.0.0.1","signal":0},"ppp0":{"status":-1,"mask":"","name":"","mac":"","ip":"","gateway":"","dns":"","signal":0},"hall":-129,"apps":{"sm":{"enabled":true,"verbose":false},"control":{"enabled":false,"verbose":false},"broker":{"enabled":true,"verbose":false},"ion":{"enabled":false,"verbose":false},"ntp":{"enabled":true,"verbose":false},"www":{"enabled":false,"verbose":false},"ssu":{"enabled":false,"verbose":false}},"disks":{"sdb_w":34,"sda":1724416,"sdc_w":360,"sda_w":0,"sdb":1724416,"sdc":243712},"wlan":{"status":-1,"mask":"255.255.255.0","name":"BGML","mac":"30:83:98:d0:9b:78","ip":"192.168.86.24","gateway":"192.168.86.1","dns":"192.168.86.1","signal":-86},"ram":{"alloc":995280,"free":1053808},"temperature":52.2,"ble":{"status":-1,"mask":"","name":"","mac":"30:83:98:d0:9b:7a","ip":"","gateway":"","dns":"","signal":8192}},"t":"status"};
const SSU = {"m":{"frame":[18,2,2,111,1,111,1,237],"frame_ts":"2022-04-23 01:27:32","time":530},"t":"ssu"};
const CONFIG =  {
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
        "mode": "ap",
        "pwd": "tigertid",
        "enabled": false,
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
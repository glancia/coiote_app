// import 'package:flutter/material.dart';
// import 'package:flutter_blue_example/telemetry.dart';
// import 'dart:async';
// import 'package:flutter_blue_example/db.dart';
//
// Future<List<Telemetry>> fetchEmployeesFromDatabase() async {
//   var dbHelper = DBHelper();
//   Future<List<Telemetry>> files = dbHelper.getTelemetrySummary();
//   return files;
// }
//
// class MyEmployeeList extends StatefulWidget {
//   @override
//   MyEmployeeListPageState createState() => new MyEmployeeListPageState();
// }
//
// class MyEmployeeListPageState extends State<MyEmployeeList> {
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       // appBar: new AppBar(
//       //   title: new Text('File List'),
//       // ),
//       body: new Container(
//         child: new FutureBuilder<List<Telemetry>>(
//           future: fetchEmployeesFromDatabase(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return new ListView.builder(
//                   itemCount: snapshot.data.length,
//                   itemBuilder: (context, index) {
//                     return new Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(children:[
//                           new Text(snapshot.data[index].id.toString(),
//                               style: new TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 14.0)),
//                           new Text(snapshot.data[index].serial.toString(),
//                               style: new TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 14.0)),
//                           new Divider()
//                           ])
//                         ]);
//                   });
//             } else if (snapshot.hasError) {
//               return new Text("${snapshot.error}");
//             }
//             return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(),);
//           },
//         ),
//       ),
//     );
//   }
// }
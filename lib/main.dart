import 'package:flutter/material.dart';
import 'package:untitled/pages/home.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.deepOrange
  ),
  home: Home(),


));




// class UserPanel extends StatefulWidget {
//   const UserPanel({Key? key}) : super(key: key);
//
//   @override
//   State<UserPanel> createState() => _UserPanelState();
// }
//
// class _UserPanelState extends State<UserPanel> {
//   int index = 0;
//
//   @override
//   Widget build(BuildContext context) {



// class MyApp extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(primaryColor: Colors.deepOrange),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Напоминания'),
//           centerTitle: true,
//         ),
//         body: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Column(
//               children: [
//                 Text('Jopa1')
//               ],
//             ),
//             Column(
//               children: [
//                 Text('Jopa2')
//               ],
//             ),
//             Column(
//               children: [
//                 Text('Jopa3')
//               ],
//             )
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.add_alert_sharp),
//           backgroundColor: Colors.deepOrange,
//           onPressed: () {
//             print('click');
//           },
//         ),
//       ),
//     );
//   }
// }
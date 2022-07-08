import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';


// class FirebaseMessagingServiceProvider {
//   static FirebaseMessagingServiceProvider _instance;
//   static final FirebaseMessaging _messaging = FirebaseMessaging();
//   static String fcmTocen;
//
//   factory FirebaseMessagingServiceProvider() =>
//       _instance ??= FirebaseMessagingServiceProvider._();
//
//   FirebaseMessagingServiceProvider._(){
//     _messaging.configure(
//       onMessage: _onMe
//     )
//   }
// }

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userToDo = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime = DateTime.now();
  bool showDateTime = false;

  String orderBy = 'datetime';
  late final List<PopupMenuEntry<Widget>> _buttons;

  // Select for Date
  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

// Select for Time
  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (selected != null && selected != selectedTime) {
      setState(() {
        selectedTime = selected;
      });
    }
    return selectedTime;
  }
  // select date time picker

  Future _selectDateTime(BuildContext context) async {
    final date = await _selectDate(context);

    final time = await _selectTime(context);
    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  timestampToString(Timestamp timestamp) {
    return DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(timestamp.toDate().toString()));
  }


  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  Widget currentValue = const Text('1 item');

  @override
  void initState() {
    super.initState();
    _buttons = [
      PopupMenuItem<Widget>(
          child: RaisedButton(
            color: Colors.white,
            onPressed: () {
              setState(() {
                orderBy = 'datetime';
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text('Сортировать по дате'),
                Icon(Icons.date_range)
              ],
            ),
          )
      ),
      PopupMenuItem<Widget>(
          child: RaisedButton(
            color: Colors.white,
            onPressed: () {
              setState(() {
                orderBy = 'item';
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text('Сортировать по названию'),
                Icon(Icons.sort_by_alpha)
              ],
            ),
          )
      ),
      PopupMenuItem<Widget>(
          child: RaisedButton(
            color: Colors.white,
            onPressed: () async {
              var collection = FirebaseFirestore.instance.collection('items');
              var snapshots = await collection.get();
              for (var doc in snapshots.docs) {
                await doc.reference.delete();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text('Удалить весь список', style: TextStyle(color: Colors.red),),
                Icon(Icons.delete_outline, color: Colors.red,)
              ],
            ),
          )
      ),
    ];
    initFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('Напоминания'),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          leading: IconButton(
            icon: const Icon(
              Icons.add_alert_sharp,
              color: Colors.white,
            ),

            onPressed: () {
              setState(() {
                showDialog(context: context, builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Добавить напоминание'),
                    content: TextField(
                        onChanged: (String value) {
                          userToDo = value;
                        },
                    ),
                    actions: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _selectDateTime(context);
                            showDateTime = true;
                          },
                          child: const Text('Выбрать дату и время'),
                        ),
                      ),

                      ElevatedButton(onPressed: () {
                        FirebaseFirestore.instance.collection('items').add({'item': userToDo, 'datetime': dateTime});
                        Navigator.of(context).pop();
                      }, child: const Text('Добавить')),

                    ],
                  );
                });
              });
            },
          ),
          actions: [ PopupMenuButton<Widget>(
            onSelected: (newValue) {
              currentValue = newValue;
            },
            itemBuilder: (context) {
              return _buttons;
            },
          ),]
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('items')
            .orderBy(orderBy)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(!snapshot.hasData) return const Text('Нет записей');
          var items = snapshot.requireData.docs;
          return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(items[index].id),
                  child: Card(
                    child: ListTile(
                      title: Text(items[index].get('item')),
                      subtitle: Text(timestampToString(items[index].get('datetime'))),
                      trailing: IconButton(
                        icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.grey
                        ),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('items').doc(items[index].id).delete();
                        },
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    FirebaseFirestore.instance.collection('items').doc(items[index].id).delete();
                  },
                );
              }
          );
        },
      ),
    );
  }
}
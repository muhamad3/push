import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push/fcm_sender_service.dart';
import 'shownotification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: ' Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NotificationsService _notificationsService = NotificationsService();
  String? token1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text('send a notification'),
              onPressed: () {
                _notificationsService.sendPushMessage(
                    tokens: [token1??''], 
                    title: "title",
                    body: "body",
                    data: {'screen': 'users'});
              },
            ),
            Container(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('token').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('erorr'),
                    );
                  }
                  List<DocumentSnapshot> doc = snapshot.data!.docs;

                  return ListView.separated(
                    itemBuilder: (context, position) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            doc[0].data().toString(),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, position) {
                      return Card(
                        color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'user $position',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    itemCount: 2,
                  );
                },
              ),
            ),ElevatedButton(
              child: Text('sending a local notification'),
              onPressed: () {
              
                  shownotificationApi.showNotification(
                    title:'title',
                    body:'body',
                    payload:'data',
                  );
              },
            )
            
          ],
        ),
      ),
    );
  }


Future gettoken() async {
  await FirebaseAuth.instance.signInAnonymously().then((userCredential) async {
    await FirebaseMessaging.instance.getToken().then((token) async {
      token1 = token;
      await FirebaseFirestore.instance
          .collection('token')
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user?.uid ?? '1', 'token': token},
              SetOptions(merge: true));
    });
  });
}}
                 
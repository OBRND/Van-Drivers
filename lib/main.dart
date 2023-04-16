import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:van_drivers/Screens/Home.dart';

import 'Screens/Navigation_screens/Wrapper.dart';
import 'Services/Auth.dart';
import 'models/User.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return StreamProvider<UserFB?>.value(
        value: Auth_service().Userx,
    initialData: null,
    child: MaterialApp(
      // home: Home(),
      home: wrapper(),
    )
    );
  }
}

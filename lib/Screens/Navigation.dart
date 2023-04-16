import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:van_drivers/Screens/Home.dart';
import 'package:van_drivers/Screens/Navigation_screens/About_us.dart';
import 'package:van_drivers/Screens/Navigation_screens/Contact_us.dart';
import 'package:van_drivers/Screens/Navigation_screens/Delivery_history.dart';
import 'package:van_drivers/Screens/Navigation_screens/Jobs.dart';
import 'package:van_drivers/Screens/Navigation_screens/Payments.dart';
import 'package:van_drivers/Screens/Navigation_screens/Pending_Deliveries.dart';
import 'package:van_drivers/Screens/Navigation_screens/Settings.dart';

import '../Services/Database.dart';
import '../models/User.dart';

class NavigationDrawerModel extends StatefulWidget {
  const NavigationDrawerModel({Key? key}) : super(key: key);

  @override
  State<NavigationDrawerModel> createState() => _NavigationDrawerModelState();
}

class _NavigationDrawerModelState extends State<NavigationDrawerModel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      width: MediaQuery.of(context).size.width * .7,
      child: Drawer(
        elevation: 0,
        backgroundColor: Color(0xffbabec0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      ),
    );
  }
  late String first = '';
  late String last = '';
  int i = 0;

  Future geturl() async{
    final FirebaseStorage storage = FirebaseStorage.instance;
    final user = FirebaseAuth.instance.currentUser!;
    print(user.uid);
    final result = await await storage.ref('Drivers/${user.uid}').getDownloadURL();
    print(result);
    return result;
  }

  Widget buildHeader(BuildContext context) {
    final user = Provider.of<UserFB?>(context);
    final uid = user!.uid;
    Future display() async {
      List Profile = await Database_service(uid: user.uid).getuserInfo();
      setState(() {
        first = Profile[0];
        last = Profile[1];
      });
    }
    if(i == 0){
      display();
      setState((){i = 1; });}
    return Material(
        color: Colors.blueAccent,
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  FutureBuilder(
                      future: geturl(),
                      builder:(context, snapshot) {
                        switch(snapshot.connectionState){
                          case ConnectionState.waiting:
                            return CircleAvatar(
                              radius: 40.0,
                              child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  )),
                            );
                        // case (ConnectionState.done) :
                          default:  return CircleAvatar(
                            radius: 40.0,
                            backgroundImage: NetworkImage('${snapshot.data}'),
                            backgroundColor: Colors.transparent,);
                        }}
                  ),
                  SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("$first $last",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget buildMenuItems(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 3, 0, 5),
    color: Colors.white12,
    child: Column(
      children: [
        SizedBox(height: 10 ),
        ListTile(
          leading: const Icon(Icons.bookmark_border),
          title: const Text('Jobs',
            style: TextStyle(fontSize: 17),),
          onTap: (){
            // to close the navigation drawer before going to the orders page
            Navigator.pop(context);

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Jobs(),
            ));

          },
        ),
        ListTile(
          leading: const Icon(Icons.pending_actions),
          title: const Text('Pending Orders',
            style: TextStyle(fontSize: 17),),
          onTap: (){
            Navigator.pop(context);

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Pending(),
            ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Delivery_history',
            style: TextStyle(fontSize: 17),),
          onTap: (){
            Navigator.pop(context);

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const Delivery_history(),
            ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.monetization_on_outlined),
          title: const Text('Payments',
            style: TextStyle(fontSize: 17),),
          onTap: (){
            Navigator.pop(context);

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const Payments(),
            ));
          },
        ),
        const Divider(color: Colors.black38),
        ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact us',
              style: TextStyle(fontSize: 17),),
            onTap: () {
              Navigator.pop(context);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Contact_us()
              ));
            }
        ),
        ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About us',
              style: TextStyle(fontSize: 17),),
            onTap: () {
              Navigator.pop(context);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>  About_us(),
              ));
            }
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

import '../../Services/Auth.dart';

class Settings extends StatelessWidget {
  // const Settings({Key? key}) : super(key: key);

  final Auth_service _auth= Auth_service();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
           child: TextButton.icon(onPressed:(){
              _auth.sign_out();
            },
              icon: Icon(Icons.door_back_door_outlined),
              label: Text('Log Out'),
            )
        ),
      ),
    );
  }
}

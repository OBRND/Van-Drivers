import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:van_drivers/Screens/Navigation_screens/Jobs.dart';
import '../../models/User.dart';
import '../Authentication/Authenticate.dart';
import '../Home.dart';

class wrapper extends StatelessWidget {
  // const ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserFB?>(context);
    print(user);
    if (user == null){
      return Authenticate();
    } else {
      return Jobs();
    }
  }

}


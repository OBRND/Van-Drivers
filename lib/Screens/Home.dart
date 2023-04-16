import 'package:flutter/material.dart';
import 'package:van_drivers/Screens/Navigation.dart';
import 'package:van_drivers/Services/Database.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Welcome Home'),
      ),
      drawer: PhysicalModel(child: const NavigationDrawerModel(),
        color: Colors.green,
        shadowColor: Colors.green,
        elevation: 20.0,),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors:[ Color(0xFF1173A8),
                  Color(0xff4d39a1)])
        ),

      ),

    );
  }

}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../Services/Auth.dart';
import '../../shared/Decorations.dart';


class Sign_in extends StatefulWidget {
  final Function switchview;
  Sign_in({required this.switchview});

  @override
  State<Sign_in> createState() => _Sign_inState();
}
class _Sign_inState extends State<Sign_in> {

  final Auth_service _auth= Auth_service();
  final _formkey = GlobalKey<FormState>();
  //text field states
  String email = '';
  String password = '';
  String error ='';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(  //loading ? Loading()
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Sign in to service'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal:20),
        child: Form(
          key: _formkey,
          child: Column(
            children: [SizedBox( height: MediaQuery.of(context).size.height*0.28),
              Text('  Let\'s get \n'
                  '  to work!', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white70),),
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),
              TextFormField(
                  decoration: textinputdecoration.copyWith(hintText: 'Email'),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val){
                    setState(() => email = val);
                  }
              ),
              SizedBox( height: 20),
              TextFormField(
                  decoration: textinputdecoration.copyWith(hintText: 'Password'),
                  validator: (val) => val!.length <6 ? 'Enter password more than 6 characters' : null,

                  obscureText: true,
                  onChanged: (val){
                    setState(() => password = val);
                  }
              ),
              SizedBox( height: 20),
              ElevatedButton(
                  // color: Colors.blue,
                  child: Text("Sign in",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async{
                    if(_formkey.currentState!.validate()){
                      // setState(() => loading = true);
                      dynamic result = await _auth.Signin_WEP(email, password);
                      // Navigator.push(context, new MaterialPageRoute(builder: (context) => new Profile(result: new result("Priyank","28"))));
                      if(result == null){
                        setState(() {
                          error = 'Could not sign in with those credentials';
                          // loading = false;
                        });
                      }
                    }
                  }
              ),
              // RaisedButton(onPressed: () async{
              //   dynamic result = await _auth.signInAnnon();
              //   print(result);
              // },child: Text('Annonymous'),),
              SizedBox( height: 20),
              Text(error,
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
        ),
        // child: RaisedButton(
        //   child: Text('Sign in Anonymously'),
        // onPressed: () async{
        //   await Firebase.initializeApp();
        //   final authservice _auth = authservice();
        //     await _auth.signInAnnon();
        //     dynamic result = await _auth.signInAnnon();
        //     if(result == null){
        //       print('Error signing in');
        //     } else {
        //       print('signed in');
        //       print(result.uid);
        //     }
        // }
        // ),
      ),
    );
  }
}

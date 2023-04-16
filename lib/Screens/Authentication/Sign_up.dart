import 'package:flutter/material.dart';


import '../../Services/Auth.dart';
import '../../shared/Decorations.dart';


class Sign_up extends StatefulWidget {
  // const Sign_up({Key? key}) : super(key: key);
  late final Function switchview;
  Sign_up({required this.switchview});

  @override
  State<Sign_up> createState() => _Sign_upState();
}

class _Sign_upState extends State<Sign_up> {

  final Auth_service _auth = Auth_service();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String First_name ='';
  String Last_name ='';
  String Phone_number = '';
  String error ="";
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      // backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Sign up to service'),
        actions: [
          TextButton.icon(onPressed:(){
            widget.switchview();
          },
            icon: Icon(Icons.person),
            label: Text('Sign in'),
          )
        ],),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal:20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox( height: 10),
              TextFormField(
                  decoration: textinputdecoration.copyWith(hintText: 'Email'),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val){
                    setState(() => email = val);
                  }
              ),
              SizedBox( height: 10),
              TextFormField(
                  decoration: textinputdecoration.copyWith(hintText: 'Password'),
                  validator: (val) => val!.length < 6 ? 'Enter password more that 6 characters' : null,
                  obscureText: true,
                  onChanged: (val){
                    setState(() => password = val);
                  }
              ),
              SizedBox( height: 10),
              TextFormField(
                  decoration: textinputdecoration.copyWith(hintText: 'First Name'),
                  validator: (val) => val!.isEmpty ? 'Enter First' : null,
                  onChanged: (val){
                    setState(() => First_name = val);
                  }
              ),
              SizedBox( height: 10),
              TextFormField(
                  decoration: textinputdecoration.copyWith(hintText: 'Last Name'),
                  validator: (val) => val!.isEmpty ? 'Enter Last name' : null,
                  onChanged: (val){
                    setState(() => Last_name = val);
                  }
              ),
              SizedBox( height: 10),
              TextFormField(
                  decoration: textinputdecoration.copyWith(hintText: 'Phone number'),
                  validator: (val) => val!.length == 10 ?   null : 'Please enter a 10 digit phone number ',
                  onChanged: (val){
                    setState(() => Phone_number = val );
                  }
              ),
              SizedBox( height: 10),
              ElevatedButton(
                  // color: Colors.blue,
                  child: Text("Register",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async{
                    if(_formKey.currentState!.validate()){
                      //   setState(() => loading = true);
                      dynamic result = await _auth.registerWEP(email, password,First_name, Last_name, Phone_number);
                      if(result == null){
                        setState((){ error ='please supply a valid email';
                          //     loading = false;
                        });
                      }
                    }
                  }
              ),
              SizedBox( height: 20),
              Text(error,
                  style: TextStyle(color: Colors.red)
              )
            ],
          ),
        ),
      ),
      //   );
      // }
    );
  }

}

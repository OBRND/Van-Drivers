import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:van_drivers/Screens/Navigation.dart';
import 'package:van_drivers/Screens/Navigation_screens/Payments.dart';
import 'package:van_drivers/Services/Database.dart';
import 'package:van_drivers/shared/Decorations.dart';

import '../../../models/User.dart';

class deposit extends StatefulWidget {
  int i;
  deposit(this.i);

  // const deposit({Key? key}) : super(key: key);

  @override
  State<deposit> createState() => _depositState(i);
}

class _depositState extends State<deposit> {
  int i;
  _depositState(this.i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Please fill the form below'),
        elevation: 0,
        backgroundColor: Colors.black12,
      ),
      drawer: NavigationDrawerModel(),
        body: Column(
          children: [
            Center(child: buildform()),
            // buildcoverphotos(context),
          ],
        ));
  }

  String First = '';
  String last = '';
  String Accountnum = '';
  String Amount = '';

  Widget buildform() {
    final user = Provider.of<UserFB?>(context, listen: false);
    return Form(
        child: Column(
          children: [
            TextFormField(
                decoration: textinputdecoration.copyWith(hintText: 'First name'),
                validator: (val) => val!.isEmpty ? 'Enter a valid account holder name' : null,
                onChanged: (val){
                  setState(() => First = val);
                }
            ),
            TextFormField(
                decoration: textinputdecoration.copyWith(hintText: 'Last name'),
                validator: (val) => val!.isEmpty ? 'Enter a valid account holder name' : null,
                onChanged: (val){
                  setState(() => last = val);
                }
            ),
            TextFormField(
                decoration: textinputdecoration.copyWith(hintText: 'Account number'),
                validator: (val) => val!.isEmpty ? 'Enter a valid account number' : null,
                onChanged: (val){
                  setState(() => Accountnum = val);
                }
            ),
            TextFormField(
                decoration: textinputdecoration.copyWith(hintText: 'Amount'),
                validator: (val) => val!.isEmpty ? 'Enter the amount to withdraw' : null,
                onChanged: (val){
                  setState(() => Amount = val);
                }
            ),
            ElevatedButton(onPressed: () async{
             await Database_service(uid: user!.uid).setdriverwithdrawals(First, last, Accountnum, Amount, i);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Payments()));
            },
                child: Text('Finish'))
          ],
        )
    );
  }

  showAlertDialog(BuildContext context) {
    final user = Provider.of<UserFB?>(context, listen: false);
    // DatabaseService databaseservice = DatabaseService(uid: user!.uid);

    // set up the buttons
    // Widget Depositbutton = FloatingActionButton(onPressed: (){
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(
    //       builder: (context) => Deposit()));
    // },
    //   child: Text("Deposit to wallet"),
    //   shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20) ),
    //   backgroundColor: Colors.indigo,
    // );
    Widget Commited_button = TextButton(onPressed: ()async{
      // await databaseservice.Deposit_Requests(Fullname, amount, DateTime.now(), Code, ['No card']);
      Navigator.of(context).pop;
    },
      child: Text("Finish"),
      // backgroundColor: Colors.black,
    );    // set up the AlertDialog

    AlertDialog alert = AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white70,
      title: Text("**Follow all the instructions below."
          " We are not responsible for any inconviniences if the instructions are incorrectly followed**",
          style:TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 15,)
      ),
      content: SelectableText.rich(
        TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 14),
          children: <TextSpan>[
            TextSpan(
              text: "1) Choose any method Namely Manual/branch, Mobile banking or CBE birr to deposit/transfer.\n"
                  "2) Deposit/transfer",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            TextSpan(
              text: " jhj br",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            TextSpan(
              text: " to account ",
            ),
            TextSpan(
              text: " 1000552626265.\n",
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            TextSpan(
                text: "3) On the deposit form use the code below as a **Reason** this is very important.\n"
                    "4) Your Account will be updated to the deposited amount within the next 12 hours.\n"
                    "5) The code is"),
            TextSpan(
              text: " $Code ",
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            TextSpan(
              text: " use this as Reason.\n ",
            ),
            TextSpan(
                text: " Beware of Capitalization of the code. ",
                style: TextStyle(color: Colors.red)
            ),
          ],
        ),
      ),

      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Depositbutton,
            // SizedBox(height: 5,),
            Commited_button,
          ],
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }



  String Code = '';

}

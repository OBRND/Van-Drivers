import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:van_drivers/Screens/Navigation.dart';
import 'package:van_drivers/Screens/Navigation_screens/Payment/Withdraw.dart';
import 'package:van_drivers/models/User.dart';

import '../../Services/Database.dart';

class Payments extends StatefulWidget {
   const Payments({Key? key}) : super(key: key);

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {

  Future getbalance() async{
    final user = Provider.of<UserFB?>(context);
    final uid = user!.uid;
    print('Here yet');
    final balance = await Database_service(uid: uid).getbalance();
    print('Here too');
    print(balance);
    return balance;
  }

  // @override
  // void initState() {
  //   // data = getbalance();
  //   // TODO: implement initState
  //   super.initState();
  // }
  late Future data;

  @override
   Widget build(BuildContext context) {
    final user = Provider.of<UserFB?>(context);
    return Scaffold(
       appBar: AppBar(
         elevation: 0,
         title: const Text('Payment'),
         backgroundColor: Colors.indigo,
       ),
       drawer: NavigationDrawerModel(),
       body:  Column(
         children: [
           Container(
             height: MediaQuery.of(context).size.height*.01,
             decoration: BoxDecoration(
               color: Colors.indigo,
               borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
             ),
           ),
           FutureBuilder(
               future: getbalance(),
               builder:(context, AsyncSnapshot snapshot) {
               switch(snapshot.connectionState) {
                 case ConnectionState.waiting:
                   return Center(
                       child: CircularProgressIndicator(
                         color: Colors.white,
                       ));
               // case (ConnectionState.done) :
                 default:
                   return Container(
                     height: MediaQuery
                         .of(context)
                         .size
                         .height * .8,
                     child: ListView(
                         children: [
                           SizedBox(height: 50),
                           Row(
                               mainAxisAlignment: MainAxisAlignment
                                   .spaceBetween,
                               children: [
                                 Padding(
                                     padding: EdgeInsets.fromLTRB(70, 0, 30, 5),
                                     child: RichText(text: TextSpan(
                                       children: [
                                         TextSpan(text: "Your Balance: ",
                                             style: TextStyle(
                                                 color: Colors.grey,
                                                 fontSize: 20)),
                                         TextSpan(text: '${snapshot.data.round()}',style:TextStyle(fontSize: 25, color: Colors.black)),
                                         TextSpan(text: ' Br.',
                                             style: TextStyle(
                                                 color: Colors.grey,
                                                 fontSize: 20)),
                                       ],),))
                                 // ElevatedButton.icon(onPressed: () {}, icon: IconButto, label: label)
                               ]
                           ),
                           // SizedBox(height: 10,),
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: FloatingActionButton(
                               onPressed: (){
                                 showscreenDialog(context);
                               },
                               shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(20)),
                               backgroundColor: Colors.indigo,
                               child: Text('Withdraw'),
                             ),
                           ),
                           SizedBox(height: 20),
                           FutureBuilder(
                             future: Database_service(uid: user!.uid).latestpayments(),
                             builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                               switch (snapshot.connectionState) {
                                 case ConnectionState.waiting:
                                   return Center(
                                       child: CircularProgressIndicator());
                                 default:
                                   List<Widget> list = <Widget>[];
                                   for (var i = 0; i < snapshot.data.length; i++) {
                                     list.add(
                                         _buildlatest(snapshot.data[i])
                                     );
                                   }
                                   return Container(
                                     height: MediaQuery
                                         .of(context)
                                         .size
                                         .height * .42,
                                     child: SingleChildScrollView(
                                       child: Column(
                                         children: [
                                           Text(' Latest payments', style: TextStyle(color: Colors.blueGrey,
                                       fontWeight: FontWeight.bold, fontSize: 20,)),
                                           Container(
                                             height: MediaQuery.of(context).size.height * .5,
                                             child: ListView(
                                               children: list,
                                             ),
                                           ),
                                           ]
                                       ),
                                     ),
                                   );
                               }
                             }
                             // child: Container(
                             //   height: 200,
                             //   child: ListView(
                             //     scrollDirection: Axis.horizontal,
                             //     children: [
                             //       Text(' Latest payments', style: TextStyle(
                             //         color: Colors.blueGrey,
                             //         fontWeight: FontWeight.bold,
                             //         fontSize: 20,)),
                             //     ],
                             //   ),
                             ),
                         ]
                     ),
                   );
               }
               }
           ),
         ],
       ),
     );
   }

   Widget _buildlatest(List snap) {
     TextStyle style1 =  TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w600);
     TextStyle style2 =  TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.w600);
     return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Amount:', style: style1,),
                  Text('${snap[0]} Br', style: style2,),
                ],
              ),
              Row(
                children: [
                  Text('Status: ', style: style1,),
                  Text('${snap[1]}', style: style2,),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Text('Withdrawn to:', style: style1,),
              Text(snap[3] == 1? 'Telebirr' : snap[3] == 2? 'CBE': snap[3] == 3? 'Awash Bank':
              snap[3] == 4? 'Birhan Bank' : snap[3] == 5? 'Abyssinia': snap[3] == 6 ? 'Dashen Bank' : 'Error in choosing Bank',
              style: style2,),
            ],
          ),
          Row(
            children: [
              Text('Account:', style: style1,),
              Text(' ${snap[2]}', style: style2,),
            ],
          ),
        ],
      ),
    );
   }

  Widget buildcoverphotos(context){
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0,20,25,20),
            child: Text('Through which bank and their service do you like to complete the payment.',
                style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
          ),
          SizedBox(height:10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2,

            children: [
              InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => deposit(1)));
                },
                child: Image.asset("Assets/img_6.png",height: 100,width: 70,),
              ),
              InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => deposit(2)));
                },
                child: Image.asset("Assets/img_3.png",height: 100,width: 70,),
              ), InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => deposit(3)));
                },
                child: Image.asset("Assets/img_4.png",height: 100,width: 70,),
              ), InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => deposit(4)));
                },
                child: Image.asset("Assets/img_5.png",height: 100,width: 70,),
              ), InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => deposit(5)));
                },
                child: Image.asset("Assets/img_7.png",height: 100,width: 70,),
              ), InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => deposit(6)));

                },
                child: Image.asset("Assets/img_8.png",height: 100,width: 70,),
              ),
            ],
          ),
        ],
      ),
    );


  }
  final _formkey = GlobalKey<FormState>();

  showscreenDialog(BuildContext context){
     showDialog(context: context,
         builder: (_)=> AlertDialog(
           contentPadding: EdgeInsets.all(10),
           scrollable: true,
           title: Text('Choose a bank to withdraw from'),
           content: Container(
               height: MediaQuery.of(context).size.height * .5,
               width: MediaQuery.of(context).size.width * .7,
               child: buildcoverphotos(context))));

   }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:van_drivers/Screens/Navigation_screens/Jobs.dart';
import 'package:van_drivers/Services/Database.dart';
import '../../../models/User.dart';
import 'Package:qr_flutter/qr_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class Finished extends StatefulWidget {
  String id;
  Finished({required this.id});

  @override
  State<Finished> createState() => _FinishedState(id);
}

class _FinishedState extends State<Finished> {
  double rating = 4;
  final CollectionReference _Orders = FirebaseFirestore.instance.collection('Orders');
  String id;
  _FinishedState(String this.id);

  Stream updateStream() {
    return _Orders.doc(id).snapshots();
    // return chats;
  }
  late String userid;
  bool x = true;
  Future getcompleted() async{
    final user = Provider.of<UserFB?>(context);
    final uid = user!.uid;
    List pay = await Database_service(uid: uid).getfinished();
    return pay;
  }
  late Future data;
@override
  void initState() {
  // TODO: implement initState
    super.initState();
    data =  getcompleted();
}
  @override
  Widget build(BuildContext context) {
    // data = getcompleted();
    final user = Provider.of<UserFB?>(context, listen: false );
    final uid = user!.uid;
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('  Proof of delivery', style: TextStyle(color: Colors.black54,fontSize: 25),),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: Center(
        child: StreamBuilder(
          stream: updateStream(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
            print(snap.data['Service type']);
            switch (snap.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default: return snap.data['Order_status'] == 'Finished' ? AlertDialog(
                title: Text('Order is finished'),
                content: Text('This delivery is successfully concluded.'),
                actions: [
                  Center(child: TextButton(onPressed: (){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => Jobs()));
                  }, child: Text('OK')))
                ],
              ) : Column(
                  children: [
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(color: Colors.black),),
                        color: Colors.white,
                        child: Text(' Delivery completed ', style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 25),)),
                    completed_details(),
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: QrImage(
                          size: MediaQuery
                              .of(context)
                              .size
                              .height * .4,
                          data: uid),
                    ),
                    ElevatedButton(onPressed: () => show_Rating(context),
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.all(10)),
                            backgroundColor: MaterialStateProperty.resolveWith<
                                Color?>((Set<MaterialState> states) =>
                            Colors.yellow)),
                        child: Text(
                          'Rate customer',
                          style: TextStyle(color: Colors.black87),)

                    ),
                    ElevatedButton(
                      onPressed: () {

                      },
                      child: Text('Complete Delivery'),
                    )
                  ],
                );
            }
          }
        ),
      ),
    );
  }

  void show_Rating(context) => showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: Text('Rate your user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children:[
            Text('How was your overall experience of the delivery', style: TextStyle(color: Colors.black87, fontSize: 19),),
            SizedBox(height: 5),
            build_rating(),
          ]),

        actions: [
          Center(child: TextButton(onPressed: (){
            print(rating);
            Navigator.of(context).pop();
          }, child: Text('OK')))
        ],

  ));

  Widget build_rating() => RatingBar.builder(
    initialRating: rating,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: true,
    itemCount: 5,
    itemSize: 30,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: Colors.amber,
    ),
    onRatingUpdate: (rating) {
      setState(() => this.rating = rating);

      print(rating);
    },
  );

  Widget completed_details(){
    return Card(
      child: FutureBuilder(
        future: getcompleted(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {

            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return Column(
                children:  [
                  Text(snapshot.data[0] == 'unpaid' ? 'The user has ${snapshot.data[1]} Br. unpaid delivery fee'
                      :'The user has paid all required delivery fee'),
                  // Text('Delivery info')
                ],
              );
          }
        }
      ),

    );
  }
}

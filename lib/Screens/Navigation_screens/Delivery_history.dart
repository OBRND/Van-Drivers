import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:van_drivers/Screens/Navigation.dart';
import 'package:van_drivers/Services/Database.dart';

import '../../models/User.dart';

class Delivery_history extends StatelessWidget {
  const Delivery_history({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserFB?>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
          title: Text('Your previous orders'),),
      drawer: NavigationDrawerModel(),
      body: FutureBuilder(
          future: Database_service(uid: user!.uid).getdriverhistory(),
          builder:(context,AsyncSnapshot snapshot) {
            TextStyle style1 =  TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w600);
            TextStyle style2 =  TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.w600);
            List<Widget> history = [];
            switch(snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ));
            // case (ConnectionState.done) :
              default:
              for(int i = 0; i < snapshot.data.length; i++){
                history.add(Card(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpandablePanel(
                    header: Row(
                      children: [
                        Text('Order ID: ', style: style1),
                        Text('${snapshot.data[i][2]}', style: style2,),
                      ],
                    ),
                    collapsed:
                    Row(
                      children: [
                        Text('Date of completion: ', style: style1,),
                        Text('${DateFormat('yyyy-MM-dd - h:mm a').format(snapshot.data[i][0])}'),
                      ],
                    ),
                    expanded: Column(
                      children: [
                        Row(
                          children: [
                            Text('Payment: ', style: style1,),
                            Text(snapshot.data[i][3].toString(), style: style1.copyWith(color: Colors.black54)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Items: ', style: style1,),
                            Text(snapshot.data[i][1].toString(), style: style1.copyWith(color: Colors.black54),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Column(
                  //   children: [
                  //     Row(
                  //       children: [
                  //         Text('Order ID: ', style: style1),
                  //         Text('${snapshot.data[i][2]} Br', style: style2,),
                  //       ],
                  //     ),
                  //     Row(
                  //       children: [
                  //         Text('Payment: ', style: style1,),
                  //         Text(snapshot.data[i][3].toString(), style: style1.copyWith(color: Colors.green),),
                  //       ],
                  //     ),
                  //     Text('${DateFormat('yyyy-MM-dd - h:mm a').format(snapshot.data[i][0])}'),
                  //   ],
                  // ),
                )));
              }
              return Container(
                height: MediaQuery.of(context).size.height * .5,
                child: ListView(
                    children: history
                ),
              );
            }
          }
          ),
    );
  }
}

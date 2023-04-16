import 'dart:math';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:van_drivers/Screens/Navigation.dart';
import 'package:van_drivers/Screens/Navigation_screens/Pending_Deliveries.dart';
import 'package:van_drivers/Services/Database.dart';
import 'package:van_drivers/shared/Order_model.dart';

import '../../models/User.dart';

class Jobs extends StatefulWidget {
  @override
  State<Jobs> createState() => _JobsState();
}

class _JobsState extends State<Jobs> {
  // const Jobs({Key? key}) : super(key: key);

  bool switchValue = false;
  bool isVisible = false;

  MapController controller = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 9.0099, longitude:38.7448),
    areaLimit: BoundingBox( east: 10.4922941, north: 47.8084648, south: 45.817995, west: 5.9559113,),

  );

  List orders = ['o','b','j','d'];
  var uidx = '';
  late String distance = '';
  late String duration = '';

  GeoPoint Start_prev = GeoPoint(latitude: 0.0, longitude: 0.0);
  GeoPoint Destination_prev = GeoPoint(latitude: 0.0, longitude: 0.0);
// double Start_lat = 0.0;
// double Start_long = 0.0;
// double Destination_lat = 0.0;
// double Destination_long = 0.0;
// GeoPoint Start = GeoPoint(latitude: 0.0, longitude: 0.0);
// GeoPoint Destination = GeoPoint(latitude: 0.0, longitude: 0.0);

  Future locatons(GeoPoint Start, GeoPoint Destination) async{

    // List x = await getlocation() as List;
    if(Start_prev != GeoPoint(latitude: 0.0, longitude: 0.0)) {
    await controller.removeMarker(Start_prev);
    await controller.removeMarker(Destination_prev);
    }
    await controller.changeLocation(
        GeoPoint(latitude: Start.latitude + 0.000000001 , longitude: Start.longitude + 0.000000001 ),
       );
    await controller.addMarker(
        GeoPoint(latitude: Destination.latitude + 0.000000001 , longitude: Destination.longitude + 0.000000001 ),
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_on,
            color: Colors.red,
            size: 56,
          ),
        ));
  var x = await drawmultipleroads(Start, Destination);
    setState(() {
      distance = '${x.distance}';
      duration = '${x.duration}';
      Start_prev = GeoPoint(latitude: Start.latitude + 0.000000001 , longitude: Start.longitude + 0.000000001);
      Destination_prev = GeoPoint(latitude: Destination.latitude + 0.000000001, longitude: Destination.longitude + 0.000000001);
    });

  }
  Future jobs() async{
    final user = Provider.of<UserFB?>(context);
    List loc = await Database_service(uid: user!.uid).getOrderlocation();
    print(loc);
    return loc;
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserFB?>(context);
    // final uid = user!.uid;
    // setState(() => uidx = uid);
    var mapController = controller;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xffe0e1e5),
      drawer: const NavigationDrawerModel(),
      appBar: AppBar(
        backgroundColor: switchValue ? Color(0xf0855d6e): Color(0xadf1f1f8),
        title: Row(
          children: [
            Text('Status'),
             Switch(
              inactiveThumbColor: Colors.red,
              activeColor: Colors.lightGreenAccent[400],
              value: switchValue,
              onChanged: (value) {
                switchValue = value;
                isVisible = !isVisible;
                setState(() {

                });
              }),
            Text(switchValue ? ' Available' : ' Off line' ,style: TextStyle(fontWeight: FontWeight.w900, color: (switchValue ? Colors.lightGreenAccent[400] : Colors.red))),

          ],
        ),
      ),
      body:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height:  MediaQuery.of(context).size.height*0.5,
            child: Stack(
              children:[
                MaterialApp(
                  home: OSMFlutter(
                    controller: mapController,
                    trackMyPosition: true,
                    initZoom: 12,
                    minZoomLevel: 8,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                    userLocationMarker: UserLocationMaker(
                      personMarker: MarkerIcon(
                        icon: Icon(
                          FontAwesomeIcons.truckFront,
                          color: Color(0xff122B91),
                          size: 40,
                        ),
                      ),
                      directionArrowMarker: MarkerIcon(
                        icon: Icon(
                          Icons.double_arrow,
                          size: 48,
                        ),
                      ),
                    ),
                    roadConfiguration: RoadConfiguration(
                      startIcon: MarkerIcon(
                        icon: Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.brown,
                        ),
                      ),
                      roadColor: Colors.yellowAccent,
                    ),
                    markerOption: MarkerOption(
                        defaultMarker: MarkerIcon(
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 56,
                          ),
                        )
                    ),

                  )
              ),
                Container(
                  color: Colors.transparent,
                    child: distance == ''? null : Column(
                      children: [
                        Text('Distance - $distance', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 16),),
                        Text('Duration - $duration')
                      ],
                    ))
    ]
            ),

          ),

          Container(
            color: Color(0xffe1e0e0),
              margin: EdgeInsets.all(0),
              // width: double.infinity,
              height: MediaQuery.of(context).size.height*.5,
              child: Column(
                children: [
                  Visibility(
                    visible: isVisible,
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 12, 0, 10),
                            child: Text('Pick an Order', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Color(
                                0xff47478a)),),
                        ),
                          FutureBuilder(
                            future: jobs(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                            switch(snapshot.connectionState){
                              case ConnectionState.waiting:
                                return Center(child: CircularProgressIndicator());
                              default: List<Widget> list = <Widget>[];
                              for(var i = 0; i < snapshot.data[0].length; i++) {
                                list.add(
                                    _build_jobs(snapshot.data[0][i], snapshot.data[1][i],snapshot.data[2][i]));
                              }
                              return Container(
                                height: MediaQuery.of(context).size.height*.42,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: list,
                                  ),
                                ),
                              );

                            //     return Padding(
                            //   padding: const EdgeInsets.fromLTRB(0, 5, 0,5),
                            //   child: snapshot.data[0].length == 1 ? _build_jobs(snapshot.data[0][0], snapshot.data[1][0],snapshot.data[2][0]) :  // for a single order
                            //   snapshot.data[0].length == 2 ? Column(children: [_build_jobs(snapshot.data[0][0], snapshot.data[1][0], snapshot.data[2][0]),
                            //     _build_jobs(snapshot.data[0][1], snapshot.data[1][1],snapshot.data[2][1])]) :  // for 2 orders
                            //   snapshot.data[0].length == 3 ? Column(children: [_build_jobs(snapshot.data[0][0], snapshot.data[1][0], snapshot.data[2][0]),
                            //     _build_jobs(snapshot.data[0][1], snapshot.data[1][1],snapshot.data[2][1]),_build_jobs(snapshot.data[0][2], snapshot.data[1][2], snapshot.data[2][2])]) :// for 3 orders
                            //   snapshot.data[0].length == 4 ? Column(children: [_build_jobs(snapshot.data[0][0], snapshot.data[1][0], snapshot.data[2][0]),
                            //     _build_jobs(snapshot.data[0][1], snapshot.data[1][1], snapshot.data[2][1]),_build_jobs(snapshot.data[0][2], snapshot.data[1][2], snapshot.data[2][2]),
                            //     _build_jobs(snapshot.data[0][3], snapshot.data[1][3], snapshot.data[2][3])]) : // for 4 orders
                            //    Column(children: [_build_jobs(snapshot.data[0][0], snapshot.data[1][0], snapshot.data[2][0]),
                            //     _build_jobs(snapshot.data[0][1], snapshot.data[1][1], snapshot.data[2][1]),_build_jobs(snapshot.data[0][2], snapshot.data[1][2], snapshot.data[2][2]),
                            //     _build_jobs(snapshot.data[0][3], snapshot.data[1][3], snapshot.data[2][3]),_build_jobs(snapshot.data[0][4], snapshot.data[1][4],  snapshot.data[2][4])]) // for 5 or more orders
                            // );
                            }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ),

        ],
      ),
    );
  }

  Widget _build_jobs(List start, List destination, Order_model details){
    String formattedDate = DateFormat.yMMMEd().format(details.Pickupdatetime);
    return Card(
      color: Colors.white70,
      child: ExpandablePanel(
          header: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                child: RichText(
                  text: TextSpan(
                  children: [
                    TextSpan(text: 'Order: ',  style: TextStyle(color: Colors.black54, fontSize: 19, fontWeight: FontWeight.w700),),
                    TextSpan(text:  '${details.Orderid}', style: TextStyle(color: Colors.black54, fontSize: 19, fontWeight: FontWeight.w400),),
              ]
                ),)
              )
            ],
          ),
          collapsed: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
            child: RichText(
              text: TextSpan(
                  children: [
                    TextSpan(text: 'Pick up time: ',  style: TextStyle(color: Colors.black54, fontSize: 19, fontWeight: FontWeight.w700),),
                    TextSpan(text:  '$formattedDate', style: TextStyle(color: Colors.black54, fontSize: 19, fontWeight: FontWeight.w400),),
                  ]
              ),)
          ),
          expanded: _Order_details(start, destination, details)
      )
    );

  }
  
  Widget _Order_details(List start, List destination, Order_model details){
    // final user = Provider.of<UserFB?>(context);
    return Column(
     crossAxisAlignment:  CrossAxisAlignment.start,
      children: [
        Text('  Items list : ',
        style: TextStyle(color: Colors.black54, fontSize: 18,fontWeight: FontWeight.w500),),
        // Text('${details} '),
        RichText(
        text: TextSpan(
        style: TextStyle(color: Colors.black54, fontSize: 13,fontWeight: FontWeight.w500),
        children: <TextSpan>[
      for(var i = 0; i< details.details.length; i++)
    ...[
    TextSpan( text: '                     Item ${i.toString()}: '),
    TextSpan( text: '${details.details[i]} \n',),
    ],

    ]
    ),),
        Center(
          child: Container(
            height: 30,
            width: 150,
            child: FloatingActionButton.extended(
                elevation: 1,
                backgroundColor: Colors.green,
                onPressed: () async{
                  GeoPoint Start =  GeoPoint(latitude: start[0], longitude: start[1]);
                  GeoPoint Destination =  GeoPoint(latitude: destination[0], longitude: destination[1]);
                  // if(Start_prev == GeoPoint(latitude: 0.0, longitude: 0.0)){
                  //
                  // }

                 // List loc = await Database_service(uid: user!.uid).getOrderlocation();
                 // // print(loc[0][0]);
                 // loc[0].length;
                 //  setState((){
                 //    Start = GeoPoint(latitude: loc[0][0], longitude: loc[1][0]);
                 //    Destination = GeoPoint(latitude: loc[1][0], longitude: loc[1][1]);
                 //
                 //  });

                  locatons(Start, Destination);
    //              Navigator.push(context,MaterialPageRoute(builder: (context) => Jobs())).then((value) { setState(() {
    //               Start =  [loc[0][0], loc[0][1]];
    //               Destination = [loc[1][0], loc[1][1]];
    //              });
    // });
                },
                label: Row(
                  children: [
                    Icon(FontAwesomeIcons.route),
                    Text('Show in Map'),
                  ],
                )),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Center(
          child: Container(
            height: 30,
            width: 110,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.indigo,
                label: Text('Pick Order'),
                onPressed: () async{
                  final user = Provider.of<UserFB?>(context, listen: false);
                  GeoPoint Start =  GeoPoint(latitude: start[0], longitude: start[1]);
                  GeoPoint Destination =  GeoPoint(latitude: destination[0], longitude: destination[1]);
                  bool check = await Database_service(uid: user!.uid).checkorderexists();
                  if(check){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('You already have another pending order'),
                    ));
                  }
                  else {
                    await Database_service(uid: user!.uid).choose_order(
                        details.Orderid, Start, Destination,details.Userid);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Pending()));
                  }
            }),
          ),
        ),SizedBox(
          height: 5,
        )
      ],
    );
    
  }

  Future drawmultipleroads (Start,Destination) async {
    // final int i = 20;
    RoadInfo roadInfo = await controller.drawRoad(
      Start,
      Destination,
      roadType: RoadType.car,
      roadOption: RoadOption(
        roadWidth: 10,
        roadColor: Colors.blue,
        showMarkerOfPOI: false,
        zoomInto: true,
      ),
    );
    print(roadInfo);
    // final listRoadInfo = await controller.drawMultipleRoad(
    //     configs,
    //     commonRoadOption: MultiRoadOption(
    //       roadColor: Colors.red,
    //       roadType: RoadType.car,)
    // );
    // var x = listRoadInfo[0];
    // print(' $x');

    // print (Config_route[0]);
    // print (Config_route[1]);
    // print (Config_route[2]);
    return roadInfo;
  }

}

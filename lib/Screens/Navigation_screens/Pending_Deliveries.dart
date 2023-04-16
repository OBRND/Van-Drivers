import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:van_drivers/Screens/Navigation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:van_drivers/Screens/Navigation_screens/Pending_Deliveries/Finished_page.dart';
import 'package:van_drivers/Services/Database.dart';
import 'package:van_drivers/shared/Order_model.dart';

import '../../models/User.dart';

class Pending extends StatefulWidget {
  const Pending({Key? key}) : super(key: key);

  @override
  State<Pending> createState() => _PendingState();
}
class _PendingState extends State<Pending> {


  MapController controller = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 9.0099, longitude:38.7448),
    areaLimit: BoundingBox(east: 10.4922941, north: 47.8084648, south: 45.817995, west: 5.9559113,),

  );

List loc = [[0.0,0.0],[0.0,0.0]];
bool i = false;
  bool floatExtended = false;
  bool checkedEn1 = false;
  bool checkedEn2 = false;
  bool clicked1 = false;
  bool clicked2 = false;
  bool checkedSubmit = false;

 late GeoPoint Start;
 // = GeoPoint(latitude: 0.0, longitude: 0.0);
 late GeoPoint Destination;
 // = GeoPoint(latitude: 0.0, longitude: 0.0);

  List<StatusWidget> _Status = [
    StatusWidget('On route to Pickup'),
    StatusWidget('Arrived at Pickup'),
    StatusWidget('Packing/loading'),
    StatusWidget('On route to Destination'),
    StatusWidget('At Destination'),
    StatusWidget('Offloading'),
  ];
  List _filters = <String>[];
  late Future data;

  Future getorder() async{
    final user = Provider.of<UserFB?>(context, listen: false );
    final uid = user!.uid;
    List current = await Database_service(uid: uid).getorder();
    if(current.isEmpty){
      print('No current order exists');
    }
    else{
      print('================');
      await controller.addMarker(
          GeoPoint(latitude: current[0][0], longitude: current[0][1]),
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 56,
            ),
          ));
      await controller.addMarker(
          GeoPoint(latitude: current[1][0], longitude: current[1][1]),
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 56,
            ),
          ));
      // setState((){
      Start = GeoPoint(latitude: current[0][0], longitude: current[0][1]);
      Destination = GeoPoint(latitude: current[1][0], longitude: current[1][1]);
      // });

      return [Start, Destination];
    }
   return [];
  }

  @override
  void initState() {
    data = getorder();
    super.initState();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  late Future update;
  bool x = true;
  Future updateloc() async{
    final user = Provider.of<UserFB?>(context, listen: false);
    while(x == true) {
        Position initPositionPoint = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        Future.delayed(Duration(seconds: 5),() async{
          await Database_service(uid: user!.uid).update_location(initPositionPoint.longitude, initPositionPoint.latitude);
          // updateloc();
        });
      // setState(() {
        // });
      }
  }
  int k = 0;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserFB?>(context, listen: false);
    final uid = user!.uid;
    var mapController = controller;
      updateloc();

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Pending Delivery',style: TextStyle(color: Colors.black87),),
        ),
        drawer: PhysicalModel(child: const NavigationDrawerModel(),
          color: Colors.green,
          shadowColor: Colors.green,
          elevation: 20.0,),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width:  MediaQuery.of(context).size.width,
              child: MaterialApp(
                home: OSMFlutter(
                  androidHotReloadSupport: true,
                    controller: mapController,
                    trackMyPosition: true,
                    initZoom: 14,
                    minZoomLevel: 8,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                    userLocationMarker: UserLocationMaker(
                      personMarker: MarkerIcon(
                        icon: Icon(
                          FontAwesomeIcons.truckFront,
                          color: Color(0xFA4A69CE),
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
                            color: Colors.lightGreen,
                            size: 56,
                          ),
                        )
                    ),
                  ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SingleChildScrollView(
                child: FutureBuilder(
                  future: data,
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default: snapshot.data == null ?
                            const Center(child: Text('You have no pending deliveries. Pick a job first.'),)
                            :
                          print('+++++++${snapshot.data}');
                          return Container(
                            // height: MediaQuery.of(context).size.height*0.25,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.spaceAround,
                                    children: companyPosition.toList(),
                                  ),
                                  ElevatedButton(onPressed: _filters.length != 6 ? null : () async{
                                    print(_filters);
                                    setState(() {
                                      x = false;
                                      checkedSubmit = true;
                                    });
                                    String id = await Database_service(uid: uid).getuserID();
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => Finished(id: id)));
                                  },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color?>((
                                            Set<MaterialState> states) =>
                                        Colors.lightGreen)),
                                    child: checkedSubmit == false ? Text(
                                        'Finish Delivery') : Icon(Icons.check),
                                  )
                                ]
                            ),
                          );
                      }
                    }),
              ),
            )
          ],
        )
    );
  }


  Iterable<Widget> get companyPosition sync* {
    final user = Provider.of<UserFB?>(context, listen: false);
    for (StatusWidget company in _Status) {
      yield Padding(
        padding: const EdgeInsets.all(0.0),
        child: FilterChip(
          backgroundColor: Color(0xff82cec4),
          // avatar: CircleAvatar(
          //   backgroundColor: Colors.cyan,
          //   child: Text(company.name[0].toUpperCase(),style: TextStyle(color: Colors.white),),
          // ),
          label: clicked1 &&  company == _Status[0] ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: _buildRouteStart())
              : clicked2 &&  company == _Status[3] ?
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: _buildRouteDestination(),
            )
              : Text(company.name,),
          selected: _filters.contains(company.name),
          selectedColor: Colors.redAccent,
          onSelected: (bool selected) {
            // getorder();
            setState(() async{
              if (selected) {
                await Database_service(uid: user!.uid).updateStatus(company.name);
                print('88888888888${company.name}');
                _filters.add(company.name);
              } else {
                _filters.removeWhere((name) {
                  if (_filters.contains('On route to Pickup')) setState(() => clicked1 = false);
                  if (_filters.contains('On route to Destination')) setState(() => clicked2 = false);
                  return name == company.name;
                });
              }
              if (_filters.contains('On route to Pickup') ) setState(() => clicked1 = true);
              if (_filters.contains('On route to Destination')) setState(() => clicked2 = true);

            });
            print('$clicked1 - $clicked2');
          },
        ),
      );
    }
  }

  Widget _buildRouteStart(){
    final user = Provider.of<UserFB?>(context, listen: false);
    return  Container(
      height: 30,
      width:  checkedEn1 == false ? 110 : 50,
      child: ElevatedButton(onPressed: () async{
       if(clicked1) setState(() => checkedEn1 = true);
       Position initPositionPoint = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       // print("This is your current Position:: " + initPositionPoint.toString());
       Database_service(uid: user!.uid).update_location(initPositionPoint.longitude,initPositionPoint.latitude);
       // loc = await Database_service(uid: user.uid ).getOrderlocation();
       // setState(() {
       //   loc = loc;
       //   Start = GeoPoint(latitude: initPositionPoint.latitude, longitude: initPositionPoint.longitude);
       //   Destination = GeoPoint(latitude: loc[0][0],longitude: loc[0][1]);
       // });
       await locatons(1);
      },
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(4)),
            backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) =>Colors.lightGreen)),
        child: checkedEn1 == false ?  Row(children: [
          Icon(FontAwesomeIcons.route, size: 14),Text('  Make Route', style: TextStyle(
            fontSize: 13
          ),) ],) : Icon(Icons.check),
      ),
    ) ;

  }
  Widget _buildRouteDestination(){
    final user = Provider.of<UserFB?>(context, listen: false);
    return  Container(
      height: 30,
      width: checkedEn2 == false ? 110 : 50,
      child: ElevatedButton(onPressed: () async{
       if(clicked2) setState(() => checkedEn2 = true);
       Position initPositionPoint = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       // print("This is your current Position:: " + initPositionPoint.toString());
       Database_service(uid: user!.uid).update_location(initPositionPoint.longitude,initPositionPoint.latitude);
       // loc = await Database_service(uid: user.uid).getOrderlocation();
       // setState(() {
       //   // loc = loc;
       //   // Start = GeoPoint(latitude: initPositionPoint.latitude, longitude: initPositionPoint.longitude);
       //   // Destination = GeoPoint(latitude: loc[1][0],longitude: loc[1][1]);
       // });
       await locatons(2);

      },
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(4)),
            backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) =>Colors.lightGreen)),
        child: checkedEn2 == false ?  Row(children: [
          Icon(  FontAwesomeIcons.route, size: 14),Text(' Make Route',  style: TextStyle(
              fontSize: 13
          ),), ],) : Icon(Icons.check),
      ),
    ) ;

  }

  Future locatons(int loc) async{
    Position initPositionPoint = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    GeoPoint(latitude: initPositionPoint.latitude, longitude: initPositionPoint.longitude);
   if(loc == 1) {
      await controller.changeLocation(Start);
    }
   else {
     await controller.changeLocation(Destination);
   }
    // await controller.addMarker(
    //     Destination,
    //     markerIcon: MarkerIcon(
    //       icon: Icon(
    //         Icons.location_on,
    //         color: Colors.red,
    //         size: 56,
    //       ),
    //     ));
    final configs = [
      MultiRoadConfiguration(
          startPoint: GeoPoint(latitude: initPositionPoint.latitude, longitude: initPositionPoint.longitude),
          destinationPoint: loc == 1 ? GeoPoint(latitude: Start.latitude+0.00000000000001,longitude: Start.longitude+0.00000000000001)
          : GeoPoint(latitude: Destination.latitude+0.00000000000001,longitude: Destination.longitude+0.00000000000001),
          roadOptionConfiguration: MultiRoadOption(
            roadColor: Colors.indigo,
          )),
    ];

    final listRoadInfo = await controller.drawMultipleRoad(
        configs,
        commonRoadOption: MultiRoadOption(
          roadColor: Colors.red,
          roadType: RoadType.car,)
    );
    var x = await listRoadInfo[0];
    print('- $x');
    return listRoadInfo;

  }

}
class StatusWidget {
  const StatusWidget(this.name);
  final String name;
}
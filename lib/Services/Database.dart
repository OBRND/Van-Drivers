
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:van_drivers/shared/Order_model.dart';

class Database_service{
  final String uid;
  Database_service({required this.uid});


  final CollectionReference _Orders = FirebaseFirestore.instance.collection('Orders');
  final CollectionReference _Driver_info = FirebaseFirestore.instance.collection('Drivers');
  final CollectionReference _current_loc = FirebaseFirestore.instance.collection('Current location');
  final CollectionReference _balance = FirebaseFirestore.instance.collection('Balance');
  final CollectionReference _history = FirebaseFirestore.instance.collection('Order_history');
  final CollectionReference _withdrawal = FirebaseFirestore.instance.collection('Withdrawal requests');
  final DbRef = FirebaseDatabase(databaseURL:"https://van-lines-default-rtdb.europe-west1.firebasedatabase.app").ref('locations');


  Future updateUserData(String First_name,String Last_name, String Phone_number) async{
    await _balance.doc(uid).set({
      'Account_holder' : '${First_name} ${Last_name} ${Phone_number}',
      'Amount': 0
    });

    return await _Driver_info.doc(uid).set({
      'First_name': First_name,
      'Last_name': Last_name,
      'Phone_number': Phone_number
    });
  }
  String generateOrderId() {
    var r = Random();
    const _chars = '0123456789''ABC''1234567890';
    return List.generate(6, (index) => _chars[r.nextInt(_chars.length)]).join();
  }

  Future setdriverwithdrawals(String first, String last, String account, String amount, int i) async{
    String x = generateOrderId();
    await _withdrawal.doc(x).set({
      'Name': '${first} ${last}',
      'Account': account,
      'Amount': double.parse(amount),
      'UID': uid,
      'Reason': '',
      'Status': 'pending',
      'Bank': i,
      'Date': DateTime.now(),
      'OrderID': x
    });
  }

  Future latestpayments() async{
    QuerySnapshot snap = await _withdrawal.where('UID', isEqualTo: uid).get();
    List x = [];
    for(int i = 0; i < snap.docs.length; i++){
      snap.docs[i]['Amount'];
      x.add([snap.docs[i]['Amount'], snap.docs[i]['Status'], snap.docs[i]['Account'], snap.docs[i]['Bank']]);
    }
    return x;
  }

  Future getfinished() async{
    String ID = await getuserID();
    print('$ID ----------------');
   DocumentSnapshot snap =await _Orders.doc(ID).get();
   snap['paid_status'];
   print(snap['Payment']);
   print('object******');
   return [snap['paid_status'],snap['Payment']];
  }

  Future getbalance() async{
    print('hey');
    DocumentSnapshot bal = await _balance.doc(uid).get();
   print('hey');
   print(bal['Amount']);
   final balance = bal['Amount'];
   print(balance);
   return balance;
  }

  Future getdriverhistory() async{
    DocumentSnapshot history = await _history.doc('Driver history').get();
    List x = [];
    print(uid);
    List list = history[uid];
    print(list);
    for(int i = 0; i < list.length; i++){
      var date = list[i]['Date of delivery'];
      print(date);
      List Items = list[i]['Items'];
      print(Items);
      String id = list[i]['Order_ID'];
      print(id);
      int payment = list[i]['payment'];
      print(payment);
      x.add([date.toDate(), Items, id, payment]);
    }
    return x;
  }

  Future updateStatus(String status) async{
    late String orderID;
    await _current_loc.where('DriverID', isEqualTo: uid).get().then(
            (value) {
          orderID = value.docs[0].id;
          print(orderID);
        });
    await _current_loc.doc(orderID).update({
      'Order_status': status
    });
  }

  Future getuserInfo() async{
    // FirebaseFirestore _instance= FirebaseFirestore.instance;

    DocumentSnapshot Driver_Profile = await _Driver_info
        .doc('$uid').get();
    var first = Driver_Profile['First_name'];
    var last = Driver_Profile['Last_name'];
    var phone = Driver_Profile['Phone_number'];

    print(first);
    print(last);
    print(phone);
    return [first,last,phone];
  }

Future update_location(double longitude, double latitude ) async {
  print(longitude);
  print(latitude);
  await DbRef.set({
    'latitude': latitude,
    'longitude': longitude
  });
}
  Future getlocation() async {
    // final ref = FirebaseDatabase.instance.ref();
    // final snapshot = await ref.child('locations').get();
    final snapshot = await DbRef.get();
    if (snapshot.exists) {
      print(snapshot.value);
      return snapshot.value;
    } else {
      print('No data available.');
    }
}

Future getuserID() async{
    late String orderID;
    late String ID;
  await _current_loc.where('DriverID', isEqualTo: uid).get().then(
          (value) async{
            print(value.docs[0]);
       orderID = value.docs[0].id;
       print(orderID);
        print('///////////////////////////////////${value.docs[0]['DriverID']}');
       await _Orders.where('Order_Id', isEqualTo: orderID).get().then((value) {
         print('herererer');
         print(value.docs);
         ID = value.docs[0].id;
         print(ID);
         print('object');
         return ID;
       });
            print('object---------');
       return ID;
          });
  await _current_loc.doc(orderID).update({
    'Order_status': 'Finished'
  });

  return ID;

}

Future getorder() async{
  late List destination = [];
  late List start = [];
  // QuerySnapshot querySnapshot = await _current_loc.get();
  await _current_loc.where('DriverID', isEqualTo: uid).get().then(
          (value) {
            destination = value.docs[0]['Destination_loc'];
            start = value.docs[0]['Start_loc'];
            print('///////////////////////////////////${value.docs[0]['DriverID']}');

            return [start, destination];
          });
  return [start, destination];
  }

  Future checkorderexists() async{
    late bool bo;
    var exists = await _current_loc.where('DriverID', isEqualTo: uid).get();
      if(exists.docs.isNotEmpty) {
        bo = true;
        return true;
      }
      else {
        bo = false;
        return false;
      }
  }
  Future choose_order(String orderID, var start, var destination, String userID) async{
    print(uid);
    await _Orders.doc(userID).update({
      'Order_status': 'In progress'
    });
    DocumentSnapshot snapshot = await _Driver_info.doc(uid).get();
    print('${snapshot['First_name']} ${snapshot['Last_name']}');
    await _current_loc.doc(orderID).set({
      'DriverID' : uid,
      'Driver' : {
        'name': '${snapshot['First_name']} ${snapshot['Last_name']}',
        'Phone_number': snapshot['Phone_number']
      },
      'Order_status': 'In progress',
      'OrderID': orderID,
      'Start_loc': [start.latitude, start.longitude],
      'Destination_loc': [destination.latitude, destination.longitude],
    });
}

  Future getOrderlocation() async{
    QuerySnapshot querySnapshot = await _Orders.get();
    List Start = [];
    List destination = [];
    List Details = [];
    late Order_model details;

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs;
        // .map((doc) => doc.data()).toList();
    // final querySnapshotc = await querySnapshot['St']
    for(int i=0; i < allData.length; i++){
      print(allData[i]['Items']);
    Start.add(allData[i]['Starting_address']);
    destination.add(allData[i]['Destination_address']);
    var x = allData[i]['Pick_Up_date'];
    DateTime date = ( x as Timestamp).toDate();
      print(date);

      details = Order_model(Orderid: allData[i]['Order_Id'], Pickupdatetime: date, details: allData[i]['Items'], Userid: allData[i].id,);
      Details.add(details);
    print('${allData[i]['Starting_address']} - $i  starting this');
    print('${allData[i]['Destination_address']} - $i Destination this');
    print(details.Orderid);
    // print(details.Pickupdatetime);

    }
    print('$Start - start');
    print('$destination - destination');


    return[Start, destination, Details];
    
  }


}
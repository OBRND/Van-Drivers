import 'package:cloud_firestore/cloud_firestore.dart';

class Order_model{
  String Orderid;
  String Userid;
  DateTime Pickupdatetime;
  List details;

Order_model({
  required this.Orderid,
  required this.Userid,
  required this.Pickupdatetime,
  required this.details,
  });

}
import 'package:cloud_firestore/cloud_firestore.dart';

class Station{
  String id;
  String name;
  GeoPoint location;
  List arrivalTimes;
  Station(this.name, this.location, this.arrivalTimes, {required this.id});
}

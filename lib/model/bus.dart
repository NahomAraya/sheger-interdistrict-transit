
import 'package:cloud_firestore/cloud_firestore.dart';

class Bus{
  String id;
  int number;
  GeoPoint location;
  String currentStation;
  int capacity;
  int passengers;
  Bus(this.number, this.location, this.currentStation, this.capacity, this.passengers,{required this.id});
}



























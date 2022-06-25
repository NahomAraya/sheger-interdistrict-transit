
import 'package:cloud_firestore/cloud_firestore.dart';

class Route{
  String id;
  List route;
  double fare;
  Route(this.route, this.fare, {required this.id});
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/net/utils.dart';

import '../ui/stationscreen.dart';




  // /LatLng destination;
GeoPoint? _initialcameraposition = GeoPoint(9.006992781288043, 38.84941534718417);
Location location = Location();
List<Destination> destinationlist = [];
  
Map shifts = {
  "afternoon": ["06:00AM", "02:59PM"],
  "morning": ["03:00PM", "01:00AM"],
  "NA": ["01:01AM", "05:59AM"]
};

Future<GeoPoint> moveTheBus(String busId) async {
  GeoPoint? _currentPosition;
  String? busShift;
  List? busRoute;
  

    //get the current bus route based on the currrent time
  for(var key in shifts.keys){
      if(checkBusStatus(shifts[key][0], shifts[key][1])){
                  busShift = key;
          }
      }
  if(busShift!="NA"){
      busRoute= await getRoute(busId, busShift);
    }
  await FirebaseFirestore.instance
      .collection("buses")
      .doc(busId)
      .get()
      .then((querySnapshot) {
           _currentPosition= querySnapshot.get("location");
                   
    });
 
    //calculate the nearest station to bus geopoint location
  distanceCalculation(_currentPosition!);
  setBusCurrStation(busId, destinationlist[0]);
  //GeoPoint? destination = await getStation(busRoute!.last);
  //calculate the number to add to the bus geo point location in order to reach the destination in 5 second intervals
  //var d = getTravelInterval(_currentPosition!.latitude, _currentPosition!.longitude, destination!.latitude, destination.longitude);
  
    //return the new bus geopoint location
  return GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);
  
}

void distanceCalculation(GeoPoint position) async {
      await FirebaseFirestore.instance
                 .collection("stations")
                 .get()
                 .then((querySnapshot) {
                   for(var result in querySnapshot.docs){
                       var km = getDistanceFromLatLonInKm(position.latitude,position.longitude, result.data()["Location"].latitude,result.data()["Location"].longitude);
                      destinationlist.add(Destination(result.data()["Location"].latitude, result.data()["Location"].longitude, result.data()["Name"]??"", distance: km ));
                      
                   }
                 });
      destinationlist.sort((a, b) {
        return a.distance.compareTo(b.distance);
      });
    
}

void setBusCurrStation(String busId, Destination d) async {
   print(d.name);
   await FirebaseFirestore.instance
              .collection("buses")
              .doc(busId)
              .update(
                {
                  'current station': d.name
                }
              );
  }

  
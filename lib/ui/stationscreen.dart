// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sit_user/ui/stationmapscreen.dart';
import '../net/utils.dart';

class StationScreen extends StatefulWidget {
  const StationScreen({ Key? key }) : super(key: key);

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  late LocationData _currentPosition;
  LatLng _initialcameraposition = LatLng(9.006992781288043, 38.84941534718417);
  Location location = Location();
  List<Destination> destinationlist = [];
  Timer? timer;
  void getLoc() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);
    distanceCalculation(_currentPosition);
     // setMarkers();
   
  }
  //sort the stations based on their proximity to the user
  distanceCalculation(LocationData position) async {
    await FirebaseFirestore.instance
                 .collection("stations")
                 .get()
                 .then((querySnapshot) {
                   for(var result in querySnapshot.docs){
                       var km = getDistanceFromLatLonInKm(_currentPosition.latitude,_currentPosition.longitude, result.data()["Location"]?.latitude,result.data()["Location"]?.longitude);
                      destinationlist.add(Destination(result.data()["Location"]?.latitude, result.data()["Location"]?.longitude, result.data()["Name"]??"", distance: km ));
                    }
                 });
    setState(() {
      destinationlist.sort((a, b) {
        return a.distance.compareTo(b.distance);
      });
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
    setState(() {
      destinationlist = destinationlist.take(5).toList();
    });
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Express Bus")),
      body: Container(
        child: destinationlist.isNotEmpty?
        ListView.builder(
            itemCount: destinationlist.length,
            itemBuilder: (context, index){
              return Card(
                margin: EdgeInsets.all(5),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    height: 80,
                    color:Colors.white,
                    child: destinationlist[index]!=null?Column(
                      children: [
                        Text(destinationlist[index].name.toString()),
                        Text("${destinationlist[index].distance.toStringAsFixed(2)} km"),
                        ElevatedButton(
                            onPressed: () {
                                Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Stationmap(destinationlist[index].lat,destinationlist[index].lng)//AddPurchase(document.refernce.id),
                                  ),
                            );
                         },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.black,
                                 
                                
                                  ),
                            child: Text('View on Map')
                            )
                      ],
                    ):
                    Text("Loading...")
                  ),
                ),
              );
            }
        ):
        Center(child: CircularProgressIndicator(),)
      ),
    );
  }
}


class Destination{
  double lat;
  double lng;
  String name;
  double distance;

  Destination(this.lat, this.lng, this.name,{required this.distance});
}


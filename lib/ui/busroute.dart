// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sit_user/net/bussimulation.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/net/networking.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_user/ui/searchscreen.dart';

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
class BusRoute extends StatefulWidget {
  final String? busid;
  final String? shift;
  final String? start;
  final String? end;
  
  BusRoute({ this.busid, this.shift, this.start, this.end, Key? key  }) : super(key: key);

  @override
  State<BusRoute> createState() => _BusRouteState();
}

class _BusRouteState extends State<BusRoute> {
  final List<LatLng> polyPoints = []; 

  final Set<Polyline> polyLines = {};

  final Set<Marker> markers = {};

  List route = [];
  var data;

  double startLat = 9.006992781288043;

  double startLng = 38.84941534718417;

  double endLat = 9.020272; 

  double endLng = 38.852366;

  double busLat = 0.0;

  double busLng = 0.0;

  //get the bus route to draw in a json format from open route service
  void getJsonData() async {
    print("getting route");
    route = await getRoute(widget.busid,widget.shift);
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format
    
    //List<String> route = <String>[];
    //DocumentSnapshot documentSnapshot = FirebaseFirestore.instance.collection('bus').doc(bus) as DocumentSnapshot<Object?>;
    
    int arrayLength=route.length;
   // var u = getStation(fromField.text);
    var s = getStation(route[0]);
    var e = getStation(route[arrayLength-1]);
    
    GeoPoint?startloc = await s;
    GeoPoint? endloc = await e;
     
   // GeoPoint? userloc = await u;

    startLat = startloc!.latitude;
    //userLat = userloc!.latitude;
    //print(userLat);
    //userLng = userloc.longitude;
    startLng = startloc.longitude;
    endLat = endloc!.latitude;
    endLng = endloc.longitude;
    NetworkHelper network = NetworkHelper(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      
    );
    

    try {
      // getData() returns a json Decoded data
      data = await network.getData();

      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      if (polyPoints.length == ls.lineString.length) {
        setPolyLines();
        drawStations();
        setState((){ loading = false; });
      }
    } catch (e) {
      print(e);
    }
  }


  //draw the polylines on the map
  setPolyLines() {
      Polyline polyline = Polyline(
      color: Colors.lightBlue,
      points: polyPoints,
      strokeWidth: 8
    );
    polyLines.add(polyline);
  }

  //initalize bus marker on its location
  void initMarker(specify, specifyId) async {
    
    bool max = await maxCapacity(specifyId);
    print(max);
    //final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
       width: 80.0,
       height: 80.0,
       point: LatLng(specify['location'].latitude, specify['location'].longitude),
       builder: (ctx) => 
                  Column(
                      children: [
                        SizedBox(width: 5,),
                        Text("Bus"+specify["number"].toString()),
                          max?
                        IconButton(
                          icon: Icon(Icons.bus_alert),
                          color: Colors.blue, 
                          onPressed: () {  },
                        ):
                        IconButton(
                          icon: Icon(Icons.bus_alert),
                          color: Colors.red, 
                          onPressed: () {  },
                    )
                      ],
                    )
                   ,
    );
    setState(() {
      markers.add(marker);
      //print(markerId);
    });
  }

  //initalize bus station markers 
  void initStationMarker(specify, specifyId) async {
    var markerIdVal = specifyId;
    final Marker marker = Marker(
       width: 80.0,
       height: 80.0,
       point: LatLng(specify['Location'].latitude, specify['Location'].longitude),
       builder: (ctx) => 
                 Column(
                    children: [
                        SizedBox(width: 5,),
                        Text(specify["Name"]),
                        IconButton(
                          icon: Icon(Icons.stop_circle),
                          color: Colors.green, 
                          onPressed: () {  },
                        )
                      ],
                    )
                   ,
    );
    setState(() {
      markers.add(marker);
      //print(markerId);
    });
  }
  
  ///get buses on the route
  void getMarkerData() async{
      FirebaseFirestore.instance.collection('buses')
        .where(FieldPath.documentId, whereIn: buses)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        initMarker(doc.data(), doc.id);
      }
    });
  }
  //get the location of the selected bus
  void getBusLocation()async{
    GeoPoint? location;
    await FirebaseFirestore.instance
                 .collection("buses")
                 .doc(widget.busid).
                 get().then((snapshot) {
      location = snapshot.get('location');
      
    });
    busLat = location!.latitude;
    busLng = location!.longitude;
  }

  //draw the stations on the map
  void drawStations(){
    FirebaseFirestore.instance.collection('stations')
        .where(FieldPath.documentId, whereIn: route)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
      
        initStationMarker(doc.data(), doc.id);
      }
    });
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(startLat, startLng),
        builder: (ctx) =>
            IconButton(
                icon: Icon(Icons.location_on),
                color: Colors.red, 
                onPressed: () {  },
                    ),
          ));
    markers.add(  
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(endLat, endLng),
        builder: (ctx) =>
              IconButton(
                icon: Icon(Icons.location_on),
                color: Colors.red, 
                onPressed: () {  },
                    ),
          ));
  } 

  
  //simulate the bus moving on the route in 5 second intervals
  void busSimulator(){
      Timer.periodic(Duration(seconds: 5), 
        (timer) async {
      GeoPoint? b = await moveTheBus(widget.busid!);
      if(this.mounted){
      setState(() {
        busLat = b.latitude;
        busLng = b.longitude;
        print(busLat);
        
      });}
        
    });
  }
  //loading variable to show loading screen
  bool loading = true;
  
  @override
  initState() {
    //map here
    super.initState();
  
    getJsonData();
    getBusLocation();
    getMarkerData();
    busSimulator();
    //if buses had physical trackers 
    // _bus_location = await Location.get_bus_location
    // _bus_location.onLocationChanged.listen((event) async {
    //   final newMarker = Marker(
    //     markerId: MarkerId('1'),
    //     position: LatLng(event.latitude, event.longitude),
    //     icon: await customIcon()
    //   );

    //   final oldMarkerIndex = _markers.indexWhere((marker) => marker.markerId == MarkerId('1'));
    //   if(oldMarkerIndex >= 0) { // If it exists
    //     setState(() { 
    //       _markers[oldMarkerIndex] = newMarker;
    //     });
    //   }
    //   await FirebaseFirestore.instance.collection("buses").doc(busId).update({
    //         location': GeoPoint(event.latitude, event.longitude)
    //    });
    //   distanceCalculation(LatLng(event.latitude, event.longitude));
    //   destinationlist.sort((a, b) {
    //     return a.distance.compareTo(b.distance);
    //   });
    //   setBusCurrStation(busId, destinationlist.first);
    // });
  }
  @override
  Widget build(BuildContext context) {
    if(loading) {
       return Center(
                      child: CircularProgressIndicator(),
                  );
     }
    return Scaffold(
      appBar: AppBar(title: Text("Express Bus")),
      body: FlutterMap(
            options: MapOptions(
            center: LatLng(busLat,busLng),
            zoom: 18.0,
          ),
            layers: [
              TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  
              ),
              MarkerLayerOptions(
                  markers: markers.toList()
              ),
              PolylineLayerOptions(
                  polylines: polyLines.toList(),
              ) 
            ],
          )
      );
  }
}
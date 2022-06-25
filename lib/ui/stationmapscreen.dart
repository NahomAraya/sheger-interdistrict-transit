// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';


class Stationmap extends StatefulWidget {
  final double StationLat;
  final double StationLng;
  Stationmap(this.StationLat, this.StationLng, { Key? key}) : super(key: key);

  @override
  State<Stationmap> createState() => _StationmapState();
}

class _StationmapState extends State<Stationmap> {
  double lat = 0.0;
  double lng = 0.0;
  @override
   initState() {
    //map here
    super.initState();
    lat = widget.StationLat;
    lng = widget.StationLng;
    setState(() {
      loading=false;
    });

    
    
  }
  bool loading = true;
  @override
  Widget build(BuildContext context) {
    print("ap");
     if(loading) {
       return Center(
                      child: CircularProgressIndicator(),
                  );
     }
     return Scaffold(
       body:FlutterMap(
            options: MapOptions(
            center: LatLng(widget.StationLat,widget.StationLng),
            zoom: 18.0,
          ),
            layers: [
              TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  
              ),
              MarkerLayerOptions(
                  markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(widget.StationLat, widget.StationLng),
                    builder: (ctx) =>
                    IconButton(
                      icon: Icon(Icons.stop_circle),
                      color: Colors.green, 
                      onPressed: () {  },
                    ),
          ),])

            ]));
  }
}
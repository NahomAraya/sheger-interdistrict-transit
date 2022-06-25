// ignore_for_file: prefer_const_constructors
//irrelevant
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/net/networking.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_user/net/utils.dart';
import 'package:sit_user/ui/busroute.dart';
import 'package:sit_user/ui/searchscreen.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
class ViewIncoming extends StatefulWidget {
  
  final String? start;
  final String? end;
  ViewIncoming({  this.start, this.end, Key? key  }) : super(key: key);

  @override
  State<ViewIncoming> createState() => _ViewIncomingState();
}

class _ViewIncomingState extends State<ViewIncoming> {
  String? busShift;
  Map shifts = {
  "morning": ["06:00AM", "02:59PM"],
  "afternoon": ["03:00PM", "01:00AM"],
  "NA": ["01:01AM", "05:59AM"]
};
 late final nameList;
  var busList;
  bool loading = true;

  //buses is a global variable which gets set at searchscreen
  getBusData() async{
      if(buses.isEmpty){
        nameList=[];
      }
      else { 

      nameList= FirebaseFirestore.instance
        .collection('buses')
        .where(FieldPath.documentId, whereIn: buses)
        .snapshots()
        ;}
      
    var documents = await FirebaseFirestore.instance
        .collection('buses')
        .where(FieldPath.documentId, whereIn: buses)
        .get();
    setState(() {
      busList = documents.docs.length;
      loading = false;
      print(busList);
    });

  }
  
  @override
  void initState() {
    super.initState();
    
    //busList= widget.buses; 
    getBusData();
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
      body: busList!=0 ?
      Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
         Expanded(
            flex: 4,
            child:StreamBuilder<QuerySnapshot>(
            stream: nameList,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          
            if(snapshot.connectionState == ConnectionState.done){
              return Center(
                    child: CircularProgressIndicator(),
                );
              }
          // if(!snapshot.hasData){
          //   return Center(
          //           child: CircularProgressIndicator(),
          //       );
          // }
            else{  
              if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                );
            }
          if (busList!=0) {
            return ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs.map((document) {
             
              return Center(
                 child:  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        
                        ListTile(
                            minVerticalPadding: 20.0,
                            minLeadingWidth: 40.0,
                           
                            leading: Icon(Icons.album),
                              title: Text("BusNumber: " + document['number'].toString()),
                              subtitle:  FutureBuilder<String?>(
                                        future: getCapacity(document.reference.id),
                                        builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                Text("Capacity: " + snapshot.data.toString()+ "/" + document["capacity"].toString()),
                                                Text("Nearest Station: " + document["current station"]),  
                                                FutureBuilder<String>(
                                                  future: getEstimatedTime(document["current station"], widget.start!),
                                                  builder: (context,snapshot) {
                                                  if (snapshot.hasData){
                                                    return Text("Estimated arrival time: " +snapshot.data.toString() + " minutes");
                                                  }
                                                  else{
                                                    return Text('Loading');
                                                  }
                                              })
                                            ]);
                                      } else {
                                              return Text('Loading...');
                                            }
                                        },
                            )),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              
                                SizedBox(width: 8),
                                Flexible(child: TextButton(
                                    child: const Text('View on Map'),
                                    
                                    onPressed: () {
                                       for(var key in shifts.keys){
                                        if(checkBusStatus(shifts[key][0], shifts[key][1])){
                                        busShift = key;
                                    }
                                  }
                                       Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BusRoute(busid: document.reference.id, start: widget.start, end: widget.end, shift: busShift,)//widget.start!, widget.end!AddPurchase(document.refernce.id),
                                ));
                          },
                        )),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );}
      else{
       return Center(
              child: Padding(
                      padding:const EdgeInsets.fromLTRB(0, 100, 0, 0),
                      child: Text(
                              "No Buses Avalible",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black),
                )));
            }
        }}
      ))])
    :
    Center(
        child: Padding(
              padding:const EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: Text("No Buses Avalible ",style: TextStyle(fontSize: 18, color: Colors.black),
          ))),
      
    );
  }
}
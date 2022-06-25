

import 'dart:math';
import  'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sit_user/net/utils.dart';


//firebase sign in function
Future<bool> signIn(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

//firebase register function
Future<bool> register(String email, String password) async {
  try {
    UserCredential result =
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email, 
          password: password,

          );
    User? user = result.user;
    await FirebaseFirestore.instance.collection('User')
      .doc(user!.uid).set({ 
        'bus_boarded':'',
        'route_booked':'',
        'start_station':'',
        'end_station':'',
        'token': 30});
    
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
    return false;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
}

//search for bus via starting and end stations and current time
Future<List> search(String from, String to, String shift) async{
  List avalilbleBuses = [];
  String busId = "";
  List busRoute = [];
  await FirebaseFirestore.instance.collection("buses").get().then((querySnapshot) async {
  for (var result in querySnapshot.docs) {
     busId = result.id.toString();
     var currentPosition = result.data()["current station"];
     
     await FirebaseFirestore.instance
                .collection("buses")
                .doc(busId)
                .collection("shifts")
                .get()
                .then((querySnapshot) async {
                    for (var result in querySnapshot.docs) {
                        if(result.data()["name"]==shift){
                        busRoute = result.data()["routePath"]; 
                        
                        if(busRoute.contains(from) && busRoute.contains(to)){
                            
                            if(busRoute.indexOf(from) < busRoute.indexOf(to)){ 
                              if(busRoute.indexOf(currentPosition) <= busRoute.indexOf(from)){
                                  
                                  avalilbleBuses.add(busId);
                            }}}                     
                     
                      
                      
                    }
                  }});
  }});

    print(avalilbleBuses);
    return avalilbleBuses;
}

//get capacity of the bus
Future<String?> getCapacity(busid) async{
   int? passengers;
   await FirebaseFirestore.instance
                 .collection("buses")
                 .doc(busid)
                 
                 //.doc(shift)
                 .get()
                 .then((querySnapshot) {
                   passengers = querySnapshot.get("passengers");
                 });
   
  print(passengers);
  return passengers.toString();

}
//check if the bus has reached max capacity of passengers
Future<bool> maxCapacity(busid) async{
  
   int? passengers;
   int? capacity;
   await FirebaseFirestore.instance
                 .collection("buses")
                 .doc(busid)
                 .get()
                 .then((querySnapshot) {
                   capacity= querySnapshot.get("capacity");
                   passengers = querySnapshot.get("passengers");
                 });
  
  return (capacity!>=passengers!);

}
//get the route of the bus at the current shift...shift is based on time
Future<List> getRoute(busid,shift) async{
  List route=[];
  List busRoute=[];
  
  await FirebaseFirestore.instance
         .collection("buses")
         .doc(busid)
         .collection("shifts")
         .get()
         .then((querySnapshot) {
            for(var result in querySnapshot.docs){
                if(result.data()["name"]==shift){
                     busRoute = result.data()["routePath"]; 
                     route = busRoute;
                        //   var routeid = result.data()["route"];
                        //   await FirebaseFirestore.instance.collection("routes").doc(routeid.toString()).get().then((querySnapshot) {
                        //          if(querySnapshot.exists){
                        //             print('Document exists');
                        //             busRoute = querySnapshot.get("route");
                        //          }
                                 
                             
                        // });
                }}});
  return route;
}

//get the station geo-coordinate  
Future<GeoPoint?> getStation(String doc) async{
  DocumentReference documentReference = FirebaseFirestore.instance
                 .collection("stations")
                 .doc(doc);
  GeoPoint? location;
  await documentReference.get().then((snapshot) {
      location = snapshot.get('Location');
  });
  return location;
}

//purhcase function...user can board any bus on a route. Return a sucessful purchase as a boolean
Future<bool> purchaseRoute(String from, String to, int fare) async {
    try {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userref = FirebaseFirestore.instance
        .collection('User')
        .doc(uid);
    
    FirebaseFirestore.instance.collection("User").doc(uid).get()
        .then((docSnapshot) async => {
          if (docSnapshot.exists) {
          //User collection has start and end station field...this will be used to check the route on purchase
            if (docSnapshot.get("token") >= fare ) {
              await FirebaseFirestore.instance.collection("User").doc(uid).update({
                          'start_station':from,
                          'end_station': to,
                  })
                  .then((value) => print("Ticket Purchased"))//check this with the bus route
            .catchError((error) => print("Failed to book bus: $error"))   
            }
        else{
          throw("You have already booked a ticket. Cancel your current booking first")
        }
      
        } else {
        // docSnapshot.data() will be undefined in this case
          throw("No such User!")
        }}).catchError((error) => 
              print("Error getting user: $error"));
    FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot1 = await transaction.get(userref);
         if (snapshot1.get("token") >= fare ) {
        int cutPass = snapshot1.get('token').round() - fare;
        transaction.update(userref, {'token': cutPass });
        return true;}
        else{
           return false;
           
        }
    });
    return true;
    } catch (e) {
    return false;
    }
}

//check if user has purchased a ticket for a route. 
Future<bool> hasUserPurchased() async {
    bool purchased = false;
    String? endStation;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {//add null check
              endStation = documentSnapshot["end_station"].toString();
        //startStation = documentSnapshot["start_station"].toString();
      }});
    print(endStation!="");
    return endStation!="";
}


getStartEndPoints() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    List stations = [];
    await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {//add null check
                stations.add(documentSnapshot["start_station"].toString());
                stations.add(documentSnapshot["end_station"].toString());
        //startStation = documentSnapshot["start_station"].toString();
      }});
    return stations;
}

//calculate fare based on distance...can be updated based on data from the actua fares  
Future<int> calculateFare(String start, String end) async {
     GeoPoint? s = await getStation(start);
     GeoPoint? e = await getStation(end);
     return ((calculateDistance(s!.latitude, s.longitude, e!.latitude, e.longitude) * 0.5) + 3).round();

}

//cancel a ticket purchased
Future<void> cancelRoute(uid) async{
    String startStation = "";
    String endStation = "";
   

    await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {//add null check
              startStation = documentSnapshot["start_station"].toString();
              endStation = documentSnapshot["end_station"].toString();
        //startStation = documentSnapshot["start_station"].toString();
      }});
     int fare = await calculateFare(startStation, endStation);
    await FirebaseFirestore.instance.collection("User").doc(uid).update({
          'start_station': "",
          'end_station': "",
          
    }).then((value) => print("Route canceled"))
    .catchError((error) => print("Failed to cancel bus: $error"));
     DocumentReference userref = FirebaseFirestore.instance
        .collection('User')
        .doc(uid);
    FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot1 = await transaction.get(userref);
         if (snapshot1.get("token") >= fare) {
        int cutPass = snapshot1.get('token').round() + fare;
        transaction.update(userref, {'token': cutPass });
        return true;}
        else{
           return false;
           
        }
    });
    

}


//calculate estimated arrival time
Future<String> getEstimatedTime(String currStation, String from) async{
    GeoPoint? s = await getStation(currStation);
    GeoPoint? e = await getStation(from);
    var t = getDistanceFromLatLonInKm(s!.latitude, s.longitude, e!.latitude, e.longitude)/20.0;
    return ((t * 60.0)+10.0).round().toString();
}
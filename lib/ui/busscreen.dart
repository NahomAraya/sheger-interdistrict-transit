// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, await_only_futures

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/ui/auth.dart';
import 'package:sit_user/ui/busroute.dart';
import 'package:sit_user/ui/home.dart';
import 'package:sit_user/ui/purchase.dart';
import 'package:sit_user/ui/qrticket.dart';
import 'package:sit_user/ui/searchscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class BusScreen extends StatefulWidget {
  final String? start;
  final String? end;
  final String? shift;
  BusScreen({ Key? key, this.shift, this.start, this.end  }) : super(key: key);

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
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
          flex: 1,
          child: Container(
          color: Colors.cyan,
          child: Row(
          children: <Widget>[
            Column(
              children: [
                Text("From: "+ widget.start.toString(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                )),
                Text("To: " + widget.end.toString(),
                    style: TextStyle(
                       fontSize: 10,
                       fontWeight: FontWeight.w500,
                        color: Colors.white,
                )),

              ],
            ),
           
                          
            FirebaseAuth.instance.currentUser == null?
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.black
                                ),
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),),
              );},
              child: Text("Login to Purchase a Ticket")
              ):  
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.black
                                ),
              onPressed: () async {
    
               //check if user has purchased a ticket;
               if(await hasUserPurchased()){
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Result'),
                      content: Text('Cannot book a ticket. You must cancel your current purchase first'),
                      actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      child: Text('Go Back'))
                        ],
                      ),
                    );
              }
                else{
                  var fare = await calculateFare(widget.start!,widget.end!);
                  if(await confirm(
                      context,
                      title: const Text('Confirm Purchase'),
                      content: Text('Fare is Birr' + fare.toString() +". Would you like to purchase?"),
                      textOK: const Text('Yes'),
                      textCancel: const Text('No'),
                  )){
                    if(await purchaseRoute(widget.start!, widget.end!, fare)){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeView(),
                          ),
                        );}
                    else{
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                            title: Text('Result'),
                            content: Text('Cannot book a ticket'),
                            actions: [
                                ElevatedButton(
                                    onPressed: () {
                                          Navigator.pop(context);
                                          },
                            child: Text('Go Back'))
                        ],
                      ),
                      );
                     }
                  }
                  return print('pressedCancel');
              }},
                  child: Text("Purchase a Ticket"),
          )]),
        )),
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
                                       Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BusRoute(busid: document.reference.id, start: widget.start, end: widget.end, shift: widget.shift,)//widget.start!, widget.end!AddPurchase(document.refernce.id),
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
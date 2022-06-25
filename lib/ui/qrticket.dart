
// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/ui/home.dart';

class QRticket extends StatefulWidget {
  const QRticket({ Key? key }) : super(key: key);

  @override
  State<QRticket> createState() => _QRticketState();
}

class _QRticketState extends State<QRticket> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;
  late DocumentSnapshot snapshot;

  GlobalKey globalKey = new GlobalKey();
  late String _dataString;
  late String _inputErrorText;
  final TextEditingController _textController =  TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
    
   //get the start and end station of the route the user purchased
  String startStation = "";
  String endStation = "";
  contentWidget() async {
    FirebaseFirestore.instance
      .collection('User')
      .doc(uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {//add null check
              setState(() {
                endStation = documentSnapshot["end_station"].toString();
        //startStation = documentSnapshot["start_station"].toString();
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contentWidget();
    setState(() {
      
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Express Bus'),
        ),
       body: 
       Container(
         color: const Color(0xFFFFFFFF),
         child: Column(

           children: <Widget>[
             endStation!=""?
              
              Column(
                 children: <Widget>[
                  ElevatedButton(
                        //button to cancel the ticket
                        onPressed: () async {
                          if(await confirm(
                            context,
                            title: const Text('Cancel Ticket'),
                            content: Text("Are you sure you want to cancel your ticket"),
                            textOK: const Text('Yes'),
                            textCancel: const Text('No'),
                        )){
                            await cancelRoute(uid);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeView(),
                              ),
                            );
                           }},
                        child: Text("Cancel Your Ticket?"),
                  ),
                  Center(
                    child: RepaintBoundary(
                          key: globalKey,
                          child: QrImage(
                            data: uid+endStation,//+startStation
                            size: 0.5 * MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom,
                            backgroundColor: Colors.white,
                        ),
                      ),
                    )
                 ])
            :Center(
                child: Padding(
                  padding:const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Text(
                        "No Ticket Booked",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                )
              )
            )
          ]
        ),
      ),
    );
  }
}
// ignore_for_file: prefer_const_constructors
//irrelevant
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/ui/home.dart';


class CancelTicket extends StatefulWidget {
  CancelTicket({ Key? key }) : super(key: key);

  @override
  State<CancelTicket> createState() => _CancelTicketState();
}

class _CancelTicketState extends State<CancelTicket> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Express Bus'),
        ),
      body: FutureBuilder<Widget>(
                future: _contentWidget(),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
                       if(snapshot.hasData) {
                          var data = snapshot.data as Widget; // Get the data as a Widget and works just fine
                          return data;
                       }

         return CircularProgressIndicator();
       }
      ),
      
    );
  }
  Future<Widget>  _contentWidget() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
   //get the data
    var endStation = '';
    await FirebaseFirestore.instance
    .collection('User')
    .doc(uid)
    .get()
    .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {//add null check
      setState(() {
        endStation = documentSnapshot.get('end_station');
       // print(busBooked);
      
      
      });}
    });
    
    return  Container(
      
      color: const Color(0xFFFFFFFF),
       child:  Column(
         children: <Widget>[
            endStation!=''?
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.black
                                  ),
              onPressed: () async {
                await cancelRoute(uid);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeView(),
                  ),
                  );
              },
                  child: Text("Cancel Your Ticket?"),
           ):Center(
                    child: Padding(
                          padding:const EdgeInsets.fromLTRB(0, 100, 0, 0),
                          child: Container(
                                    child: Text(
                                      "No Ticket Booked",
                                       style: TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    ))))

           
        ],
       ));
    }
}
// ignore_for_file: prefer_const_constructors
//irrelevant
import 'package:flutter/material.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:sit_user/ui/qrticket.dart';


class Purchase extends StatefulWidget {
  //payment here
  final int fare;
  final String start;
  final String end;
  Purchase({ Key? key, required this.fare, required this.start, required this.end }) : super(key: key);

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Express Bus")),
      body: Center(
        child: TextButton(
          child: const Text('Confirm Dialog'),
          onPressed: () async {
            if (await confirm(
              context,
              title: const Text('Confirm Purchase'),
              content: Text('Fare is' + widget.fare.toString() + " Would you like to purchase?"),
              textOK: const Text('Yes'),
              textCancel: const Text('No'),
            )) {
              //purchase and go to QR 
               if(await purchaseRoute(widget.start, widget.end, widget.fare)){
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QRticket(),
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
              //go to home page
            return print('pressedCancel');
          },
        ),
      ),
      
    );
  }
}

//////////QRCODE////////


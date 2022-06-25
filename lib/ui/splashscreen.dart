// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sit_user/ui/home.dart';

import '../pallete.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({ Key? key }) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  startTimer(){
    Timer(const Duration(seconds: 3), () async {
      Navigator.push(context, MaterialPageRoute(
      builder: (context) => const HomeView(),
    ));
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: kBlue,
           image: DecorationImage(
            image: AssetImage("assets/images/expbus.png"),
            fit: BoxFit.cover,
          ),
        ),
      
      child: Center(
        child: Column(
          children: [
             FittedBox(
                child: Image.asset('assets/images/Expresslogo.jpg', width: 100, height: 100,),
                fit: BoxFit.scaleDown,
            ),
            
          ])
        ),
      
    );
  }
}
import 'package:contactus/contactus.dart';
import 'package:flutter/material.dart';
import 'package:sit_user/pallete.dart';


class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: kBlue,
        body: ContactUs(
          companyColor: Colors.white,
          cardColor: Colors.white,
          textColor: Colors.black,
          taglineColor: Colors.white,
          companyName: 'YSHP',
          tagLine: 'Developing software',
          email: 'yourmom@gmail.com',
          phoneNumber: '09694206969',
          dividerThickness: 2,
         ),
      ),
    );
  }
}
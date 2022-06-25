// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Timetable extends StatefulWidget {
  const Timetable({ Key? key }) : super(key: key);

  @override
  State<Timetable> createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  String? dropdowntime = "morning";
  String? dropdownroute = "Megenagna Station 1 to Ayat";
  List<String?> times = ["morning", "afternoon"];
  List<String?> routes = ["Megenagna Station 1 to Ayat", "Megenagna Station 2 to Piassa"];
  Map routeabv = {"Megenagna Station 1 to Ayat": "MA",
                  "Megenagna Station 2 to Piassa" : "MP"
                };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Express Bus")),
      body: Column(children: [
         Text("Time", style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          )),
            DropdownButton(
                      value: dropdowntime,
                      onChanged: (String? value) {
                      setState(() {
                            dropdowntime = value;
                        });
                         },
                      items: times.map<DropdownMenuItem<String>>((String? value) {
                      return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value!),
                       );
                     }).toList(),
              ),
          Text("Route", style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          )),
            DropdownButton(
                      value: dropdownroute,
                      onChanged: (String? value) {
                      setState(() {
                            dropdownroute = value;
                        });
                         },
                      items: routes.map<DropdownMenuItem<String>>((String? value) {
                      return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value!),
                       );
                     }).toList(),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width/3,
                child: PhotoView(
                    imageProvider: AssetImage("assets/images/$dropdowntime${routeabv[dropdownroute]}.jpg"),
                  ),
               
        )
           
          

      ]),
    );
  }
}
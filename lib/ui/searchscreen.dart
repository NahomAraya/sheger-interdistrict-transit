// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/pallete.dart';
import '../net/utils.dart';
import 'package:sit_user/ui/busscreen.dart';


Map bus_map = {};
Map shifts = {
  "morning": ["06:00AM", "04:00AM"],
  "NA": ["04:01AM", "05:59AM"]
};
List buses = [];
TextEditingController fromField = TextEditingController();
TextEditingController toField = TextEditingController();

class SearchScreen extends StatefulWidget {
  const SearchScreen({ Key? key }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  
  
  String? busShift;
  List<String?> stations = [
    "70 Dereja Station",
    "Ayat Station",
    "Bel Air Station",
    "British Embassy Station",
    "Civil Service Station",
    "Gurdshola Station",
    "Kebena Station",
    "Megenagna Station 1",
    "Megenagna Station 2",
    "Meri Station",
    "Piassa Station",
    "Salite Meheret Station",
    "Shola Station",
    "Yetebaberut Station"

  ];
  String? dropdownStationStart = "Megenagna Station 1";
  String? dropdownStationEnd = "Megenagna Station 2";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Express Bus")),
      body: Container(
        
         width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: kBlue,
           image: DecorationImage(
            image: AssetImage("assets/images/daytime.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text("Start Station", style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
             SizedBox(
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
             Container(
                  padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(15.0),//<-- SEE HERE
                  ),
                 
             child: DropdownButton(
                        
                        value: dropdownStationStart,
                        onChanged: (String? value) {
                        setState(() {
                              dropdownStationStart = value;
                          });
                           },
                        items: stations.map<DropdownMenuItem<String>>((String? value) {
                        return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value!),
                         );
                       }).toList(),
                       )),
              SizedBox(
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
              Text("End Station", style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
            SizedBox(
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
              Container(
                  padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0), //<-- SEE HERE
                  ),
                 child: DropdownButton(
                        
                        value: dropdownStationEnd,
                        onChanged: (String? value) {
                        setState(() {
                              dropdownStationEnd = value;
                          });
                           },
                        items: stations.map<DropdownMenuItem<String>>((String? value) {
                        return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value!),
                         );
                       }).toList(),
                       )),
           
              SizedBox(
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
              Container(
                      width: MediaQuery.of(context).size.width / 1.4,
                      height: 45,
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.white,
                       ),
                      child: MaterialButton(
                        onPressed: () async{
                        
                        for(var key in shifts.keys){
                          if(checkBusStatus(shifts[key][0], shifts[key][1])){
                            busShift = key;
                          }
                        }
                        if(busShift=="NA"){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                            title: Text('SIT'),
                            content: Text('No buses operating between 10:00PM and 06:00AM'),
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
                        print(busShift);
                        buses = await search(dropdownStationStart!,dropdownStationEnd!, busShift!);
                        print("!");
                        print(buses.length);
                        //if bses [] dialog ot fod
                        if(buses.isNotEmpty){
                        Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusScreen(start:dropdownStationStart,end:dropdownStationEnd,shift: busShift!),
                              ),
                            );}
                            else{showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                            title: Text('SIT'),
                            content: Text('No buses avaliable at this time'),
                            actions: [
                                ElevatedButton(
                                    onPressed: () {
                                          Navigator.pop(context);
                                          },
                            child: Text('Go Back'))
                        ],
                      ),
                      );
                        }}},
                        child: Text("Search"),
                       ),
                      )],
            ),
      ),
      
    );
  }
}
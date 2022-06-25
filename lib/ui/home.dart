// ignore_for_file: prefer_const_constructors, avoid_print, unnecessary_new, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/ui/auth.dart';
import 'package:sit_user/ui/contactpage.dart';
import 'package:sit_user/ui/qrticket.dart';
import 'package:sit_user/ui/searchscreen.dart';
import 'package:sit_user/ui/stationscreen.dart';
import 'package:sit_user/ui/timetable.dart';
import 'package:sit_user/ui/viewincoming.dart';
import '../pallete.dart';


String? uid, email;
int? token;
String? start, end;
bool? hasuserPurchased; 
class HomeView extends StatefulWidget {
  const HomeView({ Key? key }) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late LocationData _currentPosition;
  LatLng _initialcameraposition = LatLng(9.006992781288043, 38.84941534718417);
  Location location = Location();
  final Set<Marker> markers = {};
   
 
  void getLoc() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);
    markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _initialcameraposition,
          builder: (ctx) =>
            Column(children: [
                SizedBox(width: 5,),
                Text("You"),
                IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.green, 
                  onPressed: () {  },
          )]),
    ));
     // setMarkers();
    if(FirebaseAuth.instance.currentUser != null){
      hasuserPurchased = await hasUserPurchased();
    }
    
    location.onLocationChanged.listen((LocationData currentLocation) {
        setState(() {
          _currentPosition = currentLocation;
          _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);
          loading = false;
          DateTime now = DateTime.now();
        });
    });
  }
  getToken(){
     FirebaseFirestore.instance
      .collection('User')
      .doc(uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {//add null check
              setState(() {
                token = documentSnapshot["token"];
                start = documentSnapshot["start_station"];
                end = documentSnapshot["end_station"];
        //startStation = documentSnapshot["start_station"].toString();
        });
      }
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
     
    super.initState();
    getLoc();
    getCurrentUser().then((user) {
      setState(() {
        uid = user?.uid;
        email = user?.email;
        getToken();
        
      });
    });
  }

  bool loading = true;

  @override
  Widget build(BuildContext context) {
      if(loading) {
       return Center(
                      child: CircularProgressIndicator(),
                  );
     }
    return Scaffold(
       appBar: AppBar(title: Text("Express Bus")),
       drawer: MyDrawerDirectory(),
       body: Stack(children: <Widget>[
          FlutterMap(
            options: MapOptions(
            center: _initialcameraposition,
            zoom: 18.0,
          ),
            layers: [
              TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  
              ),
              MarkerLayerOptions(
                  markers: markers.toList(),
              )]),
            
            

      ]));
    }
}

class MyDrawerDirectory extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {
    return Drawer(

      child:  Container(
      color: kBlue,
      child: Column (
        children: <Widget>[
        buildHeader(
            uid: FirebaseAuth.instance.currentUser != null? uid.toString():'',
            email: FirebaseAuth.instance.currentUser != null?email.toString():'',
            tokens: FirebaseAuth.instance.currentUser != null?token.toString():'',
            onClicked: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeView()
        ))),
          
        Expanded(
          child: ListView(
          children: [
            ListTile(leading: Icon(Icons.search), title: Text('Search for a Route'), onTap: () => _navPush(context, SearchScreen())),
            ListTile(leading: Icon(Icons.location_on),title: Text('Get Stations'), onTap: () => _navPush(context, StationScreen())),//AddPurchase( busId: "Bus1", busshift: "morning",))),
            ListTile(leading: Icon(Icons.calendar_today),title: Text('Bus Timetable'), onTap: () => _navPush(context, Timetable())),
            if(FirebaseAuth.instance.currentUser != null)ListTile(leading: Icon(Icons.airplane_ticket),title: Text('My Ticket'), onTap: () => _navPush(context, QRticket())),
            ListTile(leading: Icon(Icons.star),title: Text('Contact Us'), onTap: () => _navPush(context, ContactScreen())),
            if(FirebaseAuth.instance.currentUser != null) if(hasuserPurchased!)ListTile(leading: Icon(Icons.start), title: Text('Bus Status'), onTap: () async=> _navPush(context, ViewIncoming(start: start, end: end,))),
            FirebaseAuth.instance.currentUser != null? 
            ListTile(leading: Icon(Icons.logout),title: Text('Log Out'), onTap: () async { 
                      await FirebaseAuth.instance.signOut(); runApp(
                      new MaterialApp(
                         home: HomeView(),
                        ));}):
            ListTile(leading: Icon(Icons.login),title: Text('Log In'), onTap: () async {runApp(
                      new MaterialApp(
                        home: LoginScreen(),
                        ));},)
          ],
      )),
    ])));
  }

  Future<dynamic> _navPush(BuildContext context, Widget page) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => page,
    ));
  }
}

Widget buildHeader({
  required String uid,
    //required String urlImage,
  required String email,
  required String tokens,
  required VoidCallback onClicked,
  }) =>
  InkWell(
    
    onTap: onClicked,
    child: Container(
    padding: EdgeInsets.symmetric(vertical: 40),
    decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage("assets/images/sheger.jpeg"),
                     fit: BoxFit.cover)
              ),
    child: Row(
            children: [
             // CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    "SIT Tokens: " + tokens.toString(),
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              Spacer(),
              CircleAvatar(
                radius: 24,
                backgroundColor: Color.fromRGBO(30, 60, 168, 1),
                child: Icon(Icons.add_comment_outlined, color: Colors.white),
              )
            ],
          ),
        ),
    );


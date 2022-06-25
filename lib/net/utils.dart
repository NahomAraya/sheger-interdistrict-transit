import 'dart:math';
import 'package:flutter/material.dart';
import  'package:intl/intl.dart';

double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    
    return 12742 * asin(sqrt(a));
  }

double getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1);
  var a =
      sin(dLat/2) * sin(dLat/2) +
          cos(deg2rad(lat1)) * cos(deg2rad(lat2)) *
              sin(dLon/2) * sin(dLon/2)
  ;
  var c = 2 * atan2(sqrt(a), sqrt(1-a));
  var d = R * c; // Distance in km
  return d;
}



double deg2rad(deg) {
  return deg * (pi/180);
}
//checks if restaurant is open or closed 
// returns true if current time is in between given timestamps
//openTime HH:MMAM or HH:MMPM same for closedTime
bool checkBusStatus(String openTime, String closedTime) {
    //NOTE: Time should be as given format only
    //10:00PM
    //10:00AM

    // 01:60PM ->13:60
    //Hrs:Min
    //if AM then its ok but if PM then? 12+time (12+10=22)

    TimeOfDay timeNow = TimeOfDay.now();
    String openHr = openTime.substring(0, 2);
    String openMin = openTime.substring(3, 5);
    String openAmPm = openTime.substring(5);
    TimeOfDay timeOpen;
    if (openAmPm == "AM") {
      //am case
      if (openHr == "12") {
        //if 12AM then time is 00
        timeOpen = TimeOfDay(hour: 00, minute: int.parse(openMin));
      } else {
        timeOpen =
            TimeOfDay(hour: int.parse(openHr), minute: int.parse(openMin));
      }
    } else {
      //pm case
      if (openHr == "12") {
//if 12PM means as it is
        timeOpen =
            TimeOfDay(hour: int.parse(openHr), minute: int.parse(openMin));
      } else {
//add +12 to conv time to 24hr format
        timeOpen =
            TimeOfDay(hour: int.parse(openHr) + 12, minute: int.parse(openMin));
      }
    }

    String closeHr = closedTime.substring(0, 2);
    String closeMin = closedTime.substring(3, 5);
    String closeAmPm = closedTime.substring(5);

    TimeOfDay timeClose;

    if (closeAmPm == "AM") {
      //am case
      if (closeHr == "12") {
        timeClose = TimeOfDay(hour: 0, minute: int.parse(closeMin));
      } else {
        timeClose =
            TimeOfDay(hour: int.parse(closeHr), minute: int.parse(closeMin));
      }
    } else {
      //pm case
      if (closeHr == "12") {
        timeClose =
            TimeOfDay(hour: int.parse(closeHr), minute: int.parse(closeMin));
      } else {
        timeClose = TimeOfDay(
            hour: int.parse(closeHr) + 12, minute: int.parse(closeMin));
      }
    }

    int nowInMinutes = timeNow.hour * 60 + timeNow.minute;
    int openTimeInMinutes = timeOpen.hour * 60 + timeOpen.minute;
    int closeTimeInMinutes = timeClose.hour * 60 + timeClose.minute;

//handling day change ie pm to am
    if ((closeTimeInMinutes - openTimeInMinutes) < 0) {
      closeTimeInMinutes = closeTimeInMinutes + 1440;
      if (nowInMinutes >= 0 && nowInMinutes < openTimeInMinutes) {
        nowInMinutes = nowInMinutes + 1440;
      }
      if (openTimeInMinutes < nowInMinutes &&
          nowInMinutes < closeTimeInMinutes) {
        return true;
      }
    } else if (openTimeInMinutes < nowInMinutes &&
        nowInMinutes < closeTimeInMinutes) {
      return true;
    }

    return false;

  }


getTravelInterval(lat1, lng1, lat2, lng2){
  double latInterval = (lat2-lat1)/5;
  double lngInterval  = (lng2-lng1)/5;
  return[latInterval,lngInterval];

}
//port 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:location_sorting_app/Destination.dart';
// import 'package:location_sorting_app/Utils.dart';

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   Position _currentPosition;
//   List<Destination> destinationlist = List<Destination>();

//   @override
//   void initState() {
//     _getCurrentLocation();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Location sorting from current location"),
//       ),
//       body: Container(
//         child: destinationlist.length>0?
//         ListView.builder(
//             itemCount: destinationlist.length,
//             itemBuilder: (context, index){
//               return Card(
//                 margin: EdgeInsets.all(5),
//                 elevation: 5,
//                 child: Padding(
//                   padding: EdgeInsets.all(5),
//                   child: Container(
//                     height: 40,
//                     color:Colors.white,
//                     child: Column(
//                       children: [
//                         Text("${destinationlist[index].name}"),
//                         Text("${destinationlist[index].distance.toStringAsFixed(2)} km"),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }
//         ):
//         Center(child: CircularProgressIndicator(),)
//       )
//     );
//   }

//   // get Current Location
//   _getCurrentLocation() {
//     Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.best,
//             forceAndroidLocationManager: true)
//         .then((Position position) {
//       distanceCalculation(position);
//       setState(() {
//         _currentPosition = position;
//       });
//     }).catchError((e) {
//       print(e);
//     });
//   }

//   distanceCalculation(Position position) {
//     for(var d in destinations){
//       var km = getDistanceFromLatLonInKm(position.latitude,position.longitude, d.lat,d.lng);
//       // var m = Geolocator.distanceBetween(position.latitude,position.longitude, d.lat,d.lng);
//       // d.distance = m/1000;
//       d.distance = km;
//       destinationlist.add(d);
//       // print(getDistanceFromLatLonInKm(position.latitude,position.longitude, d.lat,d.lng));
//     }
//     setState(() {
//       destinationlist.sort((a, b) {
//         return a.distance.compareTo(b.distance);
//       });
//     });
//   }
// }
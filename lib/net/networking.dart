
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sit_user/net/.env.dart';

class NetworkHelper{
  NetworkHelper({required this.startLng,required this.startLat,required this.endLng,required this.endLat});

  final String url ='https://api.openrouteservice.org/v2/directions/';
  final String apiKey = orsAPIKey;
  final String journeyMode = 'driving-car'; // Change it if you want or make it variable
  //final String url = 'https://api.openrouteservice.org/v2/directions/driving-car';
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;
   Map<String, String> header = <String, String>{
     'Content-Type': 'application/json; charset=utf-8',
     'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
     'Authorization': '5b3ce3597851110001cf624873f36d106af649418ec77a5d4692baa6'};
   Map<String, String> body = {
    'coordinates': json.encode(
      {"coordinates":[[8.681495,49.41461],[8.686507,49.41943],[8.687872,49.420318]]},
    ),
    
  };
  Future getData() async{
    http.Response response = await http.get(Uri.parse('$url$journeyMode?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat'));
    print("$url$journeyMode?$apiKey&start=$startLng,$startLat&end=$endLng,$endLat");

    if(response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);

    }
    else{
      print(response.statusCode);
    }
   // http.Response response2 = await http.post(Uri.parse(url), headers:header, body: body);
  }
}

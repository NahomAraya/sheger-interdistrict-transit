class User{
  String id;
  String email;
  String password;
  String busBooked;
  String routeBooked;
  String startStation;
  String endStation;
  User(this.busBooked, this.routeBooked, this.startStation, this.endStation,{required this.id, required this.email, required this.password});
}
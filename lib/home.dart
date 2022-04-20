import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pingme/friends.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingme/authentication/login.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState(); //init class HomeState
}

Future<Position> _getGeoLocationPosition() async {
  return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

class HomeState extends State<HomePage> {
  late Position _currentPosition;
  late GoogleMapController
      mapController; //load google apps function from google_maps_flutter plugin
  LatLng initcamposition =
      const LatLng(45.521563, -122.677433); //default cam position
  Location location =
      Location(); //enable location tracking from user device using location plugin
  final firestoreInstance = FirebaseFirestore.instance;

  void _onMapCreated(GoogleMapController controller) {
    //create map
    mapController = controller; //allow for looking around map
    location.onLocationChanged.listen((l) {
      //listen to user current position
      mapController.animateCamera(
        //lock onto user position
        CameraUpdate.newCameraPosition(
          //update if user position changes
          CameraPosition(
              target: LatLng(l.latitude!, l.longitude!),
              zoom: 16), //fetch new position
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('PingMe'),
            backgroundColor: Colors.blue,
            centerTitle: true,
            leading: IconButton(
              //settings button
              icon: const Icon(Icons.settings),
              onPressed: () {},
            )),
        body: GoogleMap(
          onMapCreated: _onMapCreated, //build map
          initialCameraPosition: CameraPosition(
            target: initcamposition, //initial position
            zoom: 1.0, //initial zoom (globe)
          ),
          myLocationEnabled: true, //allow for permission to track user
        ),
        bottomNavigationBar: BottomAppBar(
          //footer navigation bar
          shape: const CircularNotchedRectangle(), //navigation bar layout
          notchMargin: 6.0,
          color: Colors.blue,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                color: Colors.white,
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {});
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
              ),
              const Spacer(), //allow for friends icon to appear right side

              IconButton(
                  icon:
                      const Icon(Icons.perm_identity_outlined, //friends button
                          color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FriendsPage()));
                  }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            //map button
            child: const Icon(Icons.public),
            onPressed: () async {
              Position geoPosition = await _getGeoLocationPosition();
              var firebaseUser = FirebaseAuth.instance.currentUser;
              if (firebaseUser != null) {
                await firestoreInstance
                    .collection("userEmails")
                    .doc(firebaseUser.uid)
                    .update({
                  'location':
                      GeoPoint(geoPosition.latitude, geoPosition.longitude)
                });
              }
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                          title: const Text('Current Location'),
                          content: Text(
                              "LAT: ${geoPosition.latitude}, LNG: ${geoPosition.longitude}"),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            )
                          ]));
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
  /*
  _getCurrentLocation() {
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }
  */
}

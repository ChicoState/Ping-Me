import 'dart:async';
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

class HomeState extends State<HomePage> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  late GoogleMapController mapController;
  LatLng initcamposition = const LatLng(45.521563, -122.677433);
  Location location = Location();
  final firestoreinstance = FirebaseFirestore.instance;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Timer? timer;
  bool toggleLocation = false;
  Color toggleColor = Colors.red;
  bool allowTracking = false;
  var currentTime;

  @override
  void initState() {
    getMarkerData();
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => getMarkerData());
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => updateLocation());
  }

  //FETCH USER POSITION
  Future<Position> _getGeoLocationPosition() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  //COLLECT AND PROCESS ALL USERS IN FIREBASE FOR CREATING MARKERS
  getMarkerData() async {
    // setState(() {
    // Looking for users from the friends list
    markers = <MarkerId, Marker>{};
    FirebaseFirestore.instance
        .collection('userEmails')
        .doc(_uid)
        .collection('friends')
        .get()
        .then((friendDocs) {
      if (friendDocs.docs.isNotEmpty) {
        for (int i = 0; i < friendDocs.docs.length; i++) {
          if (friendDocs.docs[i]['tracking']) {
            var friendUid = friendDocs.docs[i].id;
            FirebaseFirestore.instance
                .collection('userEmails')
                .doc(friendUid)
                .get()
                .then((userData) {
              initMarker(userData.data(), userData.id);
            });
          }
        }
      }
    });
    // });
  }

  //CREATE MARKER BASED OFF OF USER DATA IN FIREBASE
  void initMarker(specify, specifyId) async {
    setState(() {
      var markeridvalue = specifyId;
      final MarkerId markerId = MarkerId(markeridvalue);
      //create marker with user location, username, and time
      final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(specify['location'].latitude, specify['location'].longitude),
        infoWindow: InfoWindow(
            title: specify['username'],
            snippet: specify['time'].toDate().toString()),
      );
      //push marker into Map array for displaying in Google Maps
      markers[markerId] = marker;
    });
  }

  //ALLOW CONTROL OF GOOGLE MAPS
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller; //allow for looking around map
    location.changeSettings(interval: 1000000);
    location.onLocationChanged.listen((l) {
      //lock onto user position at log-in
      mapController.animateCamera(
        //update camera if user position changes
        CameraUpdate.newCameraPosition(
          //update if user position changes
          CameraPosition(
              target: LatLng(l.latitude!, l.longitude!),
              zoom: 14), //fetch new position
        ),
      );
    });
  }

  void updateLocation() async {
    if (toggleLocation == true) {
      Position geoPosition = await _getGeoLocationPosition();
      var firebaseUser = FirebaseAuth.instance.currentUser;
      currentTime = Timestamp.now().toDate().toString();
      if (firebaseUser != null) {
        await firestoreinstance
            .collection("userEmails")
            .doc(firebaseUser.uid)
            .update({
          'location': GeoPoint(geoPosition.latitude, geoPosition.longitude),
          'time': Timestamp.now(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //PING-ME APP HEADER
        appBar: AppBar(
          title: const Text('PingMe'),
          backgroundColor: Colors.blue,
          centerTitle: true,
          actions: [
            Switch(
                activeColor: Colors.white,
                value: allowTracking,
                onChanged: (value) => setState(() {
                      allowTracking = value;
                    }))
          ],
        ),
        //GOOGLE MAPS GUI, WITH MARKERS AND USER LOCATION
        body: Stack(
          children: [
            GoogleMap(
              markers: Set<Marker>.of(markers.values),
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: initcamposition,
                zoom: 1.0,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
            ),
            Positioned(
                top: 3.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 6.0),
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        )
                      ]),
                  child: Text(
                    'Last Ping: $currentTime',
                    style: const TextStyle(color: Colors.white),
                  ),
                ))
          ],
        ),
        //FOOTER WITH FRIENDS, PING BUTTON, AND LOGOUT
        bottomNavigationBar: BottomAppBar(
          //footer navigation bar
          shape: const CircularNotchedRectangle(), //navigation bar layout
          notchMargin: 6.0,
          color: Colors.blue,
          child: Row(
            children: [
              IconButton(
                //LOGOUT BUTTON
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
              const Spacer(),
              //FRIENDS BUTTON
              IconButton(
                  icon: const Icon(Icons.perm_identity_outlined,
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
        //PING BUTTON
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.public),
          onPressed: () async {
            setState(() {
              if (toggleLocation == false) {
                toggleColor = Colors.red;
                toggleLocation = true;
              } else if (toggleLocation == true) {
                toggleColor = Colors.green;
                toggleLocation = false;
              }
            });
          },
          backgroundColor: toggleColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

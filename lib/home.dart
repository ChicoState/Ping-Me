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
  Color toggleColor = Colors.green;
  String? currentTime;

  @override
  void initState() {
    getMarkerData();
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => getMarkerData());
    timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => updateLocationHistory());
  }

  //COLLECT AND PROCESS ALL USERS IN FIREBASE FOR CREATING MARKERS
  void getMarkerData() async {
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
              initMarker(userData.data(), friendUid);
            });
          }
        }
      }
    });
  }

  //CREATE MARKER BASED OFF OF USER DATA IN FIREBASE
  void initMarker(userDoc, userId) async {
    setState(() {
      //create marker with user location, username, and time
      if (userDoc.containsKey('locationHistory') && userDoc['allowTracking']) {
        int index = 0;
        for (var element in userDoc['locationHistory']) {
          String markerIdString = userId + index.toString();
          MarkerId locationId = MarkerId(markerIdString);
          // MarkerId(element.latitude.toString() + element.longitude);
          final Marker marker = Marker(
            markerId: locationId,
            position: LatLng(element.latitude, element.longitude),
            infoWindow: InfoWindow(
                title: userDoc['username'] + ': ' + (index + 1).toString(),
                snippet: userDoc['timeHistory'][index].toDate().toString()),
          );
          //push marker into Map array for displaying in Google Maps
          markers[locationId] = marker;
          index++;
        }
      }
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

  Future<void> updateLocationHistory() async {
    if (toggleLocation == true) {
      List<GeoPoint> locationHistory = <GeoPoint>[];
      List<Timestamp> timeHistory = <Timestamp>[];

      // Getting the current location history from firestore
      await FirebaseFirestore.instance
          .collection('userEmails')
          .doc(_uid)
          .get()
          .then((userData) {
        if (userData.data()!.containsKey('locationHistory')) {
          for (var element in List.from(userData.data()!['locationHistory'])) {
            locationHistory.add(element);
          }
        }
        if (userData.data()!.containsKey('timeHistory')) {
          for (var element in List.from(userData.data()!['timeHistory'])) {
            timeHistory.add(element);
          }
        }
      });

      // Popping off the oldest entry
      if (locationHistory.length > 9) {
        locationHistory.removeLast();
      }
      if (timeHistory.length > 9) {
        timeHistory.removeLast();
      }

      // Adding current location and time to list
      Position curPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      locationHistory.insert(0, GeoPoint(curPos.latitude, curPos.longitude));
      timeHistory.insert(0, Timestamp.now());
      currentTime = timeHistory[0].toDate().toString();

      // Pushing the lists to the database
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('userEmails')
            .doc(_uid)
            .update({
          'locationHistory': locationHistory,
          'timeHistory': timeHistory,
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
            // ALLOW TRACKING TOGGLE
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('userEmails')
                  .doc(_uid)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Switch(
                      activeColor: Colors.white,
                      value: snapshot.data['allowTracking'],
                      onChanged: (value) {
                        FirebaseFirestore.instance
                            .collection('userEmails')
                            .doc(_uid)
                            .update({'allowTracking': value});
                        showDialog(
                            context: context,
                            builder: (context) {
                              Future.delayed(const Duration(seconds: 3), () {
                                Navigator.of(context).pop(true);
                              });
                              if (value) {
                                return AlertDialog(
                                  title: RichText(
                                    text: const TextSpan(
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Tracking is now turned '),
                                          TextSpan(
                                              text: 'on',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                  ),
                                  content: const Text(
                                      'Your friends can now see your previous locations.'),
                                );
                              } else {
                                return AlertDialog(
                                  title: RichText(
                                    text: const TextSpan(
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Tracking is now turned '),
                                          TextSpan(
                                              text: 'off',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                  ),
                                  content: const Text(
                                      'Your friends cannot see your previous locations.'),
                                );
                              }
                            });
                      });
                }
                return const Switch(
                  value: false,
                  onChanged: null,
                );
              },
            ),
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
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
            (currentTime != null)
                ? Positioned(
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
                : const SizedBox.shrink()
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
              // Turning on location
              if (!toggleLocation) {
                toggleColor = Colors.red;
                toggleLocation = true;
                FirebaseFirestore.instance
                    .collection('userEmails')
                    .doc(_uid)
                    .update({
                  'allowTracking': true,
                });
              } else {
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

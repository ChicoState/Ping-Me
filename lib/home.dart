import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  late GoogleMapController mapController;
  LatLng initcamposition = LatLng(45.521563, -122.677433);
  Location location = Location();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    location.onLocationChanged.listen((l) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 16),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Ping-Me'),
            backgroundColor: Colors.blue,
            centerTitle: true,
            leading: IconButton(
            icon: const Icon(Icons.settings),
              onPressed: () {},
            )),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: initcamposition,
            zoom: 1.0,
          ),
          myLocationEnabled: true,
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          color: Colors.blue,
          child: Row(
            children: [
              //IconButton(icon: Icon(Icons.menu), onPressed: () {}),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.perm_identity_outlined,
                      color: Colors.white),
                  onPressed: () {}),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.public), onPressed: () {}),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng? _currentLocation;
  Marker? _currentMarker;
  List<LatLng> _polylineCoordinates = [];
  Polyline? _polyline;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // Request location permission
    PermissionStatus permission = await _location.requestPermission();
    if (permission != PermissionStatus.granted) return;

    // Enable real-time location tracking
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng newLocation = LatLng(locationData.latitude!, locationData.longitude!);
        setState(() {
          _currentLocation = newLocation;

          // Add marker
          _currentMarker = Marker(
            markerId: MarkerId('currentLocation'),
            position: newLocation,
            infoWindow: InfoWindow(
              title: 'My current location',
              snippet: 'Lat: ${newLocation.latitude}, Lng: ${newLocation.longitude}',
            ),
          );

          // Update polyline
          _polylineCoordinates.add(newLocation);
          _polyline = Polyline(
            polylineId: PolylineId('route'),
            points: _polylineCoordinates,
            color: Colors.blue,
            width: 5,
          );

          // Move camera smoothly
          _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map with Location Tracking"),
        backgroundColor: Colors.blue,
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 15,
        ),
        markers: _currentMarker != null ? {_currentMarker!} : {},
        polylines: _polyline != null ? {_polyline!} : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

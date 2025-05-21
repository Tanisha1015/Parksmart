// lib/screens/navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/providers/location_provider.dart';

class NavigationScreen extends StatefulWidget {
  final LatLng destinationLatLng;

  const NavigationScreen({
    super.key,
    required this.destinationLatLng,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Replace with your own Google Maps API Key
  final String _googleApiKey = '';

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  Future<void> _getRoute() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      if (locationProvider.currentPosition == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to get current location';
        });
        return;
      }
      
      final origin = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );
      
      final destination = widget.destinationLatLng;
      
      // Get directions
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        _googleApiKey,
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );
      
      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = [];
        
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        
        Polyline polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        );
        
        setState(() {
          _polylines = {polyline};
        });
      } else {
        setState(() {
          _errorMessage = 'Unable to find a route';
        });
      }
      
      // Set markers
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('origin'),
            position: origin,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            infoWindow: const InfoWindow(title: 'Parking Lot'),
          ),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error getting directions: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    if (locationProvider.currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation'),
        ),
        body: const Center(
          child: Text('Unable to get current location'),
        ),
      );
    }
    
    final origin = LatLng(
      locationProvider.currentPosition!.latitude,
      locationProvider.currentPosition!.longitude,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: origin,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              
              // Zoom to show both markers
              LatLngBounds bounds = LatLngBounds(
                southwest: LatLng(
                  min(origin.latitude, widget.destinationLatLng.latitude),
                  min(origin.longitude, widget.destinationLatLng.longitude),
                ),
                northeast: LatLng(
                  max(origin.latitude, widget.destinationLatLng.latitude),
                  max(origin.longitude, widget.destinationLatLng.longitude),
                ),
              );
              
              controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
            },
          ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

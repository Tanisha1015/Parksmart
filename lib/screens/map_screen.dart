// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/models/parking_lot.dart';
import 'package:park_smart/providers/location_provider.dart';
import 'package:park_smart/providers/parking_provider.dart';
import 'package:park_smart/screens/parking_lot_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  static const double _searchRadius = 5000; // 5 km

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMarkers();
  }

  void _updateMarkers() {
  final locationProvider = Provider.of<LocationProvider>(context);
  final parkingProvider = Provider.of<ParkingProvider>(context);

  if (locationProvider.currentPosition == null) {
    return;
  }

  final userLocation = LatLng(
    locationProvider.currentPosition!.latitude,
    locationProvider.currentPosition!.longitude,
  );

  // Find nearby parking lots
  final nearbyParkingLots = parkingProvider.findNearbyParkingLots(userLocation, _searchRadius);

  // Create markers for each parking lot
  setState(() {
    _markers = {
      Marker(
        markerId: const MarkerId('user_location'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'Your Location',
        ),
      ),
      // --- HARDCODED MARKER FOR TESTING ---
      Marker(
        markerId: const MarkerId('hardcoded_test_marker'),
        position: const LatLng(22.7838587, 75.2606084), // Use any coordinates you like
        infoWindow: const InfoWindow(
          title: 'Test Marker',
          snippet: 'available',
        ),
      ),
    };

    // Add markers for parking lots from Firebase
    for (final lot in nearbyParkingLots) {
      _markers.add(
        Marker(
          markerId: MarkerId('lot_${lot.id}'),
          position: LatLng(lot.latitude, lot.longitude),
          infoWindow: InfoWindow(
            title: lot.name,
            snippet: '${lot.availableSpots} spots available',
            onTap: () => _onMarkerTapped(lot),
          ),
          onTap: () => _onMarkerTapped(lot),
        ),
      );
    }
  });
}


  void _onMarkerTapped(ParkingLot parkingLot) {
    final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
    parkingProvider.selectParkingLot(parkingLot);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ParkingLotDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    // If still loading location
    if (locationProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // If there's an error with location
    if (locationProvider.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locationProvider.errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await locationProvider.getCurrentLocation();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // If location is available
    if (locationProvider.currentPosition != null) {
      final userLocation = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );
      
      return Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLocation,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(userLocation),
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      );
    }
    
    // Fallback
    return const Center(
      child: Text('Unable to get location. Please check your settings.'),
    );
  }
}

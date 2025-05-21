// lib/screens/parking_lot_details_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/models/parking_spot.dart';
import 'package:park_smart/providers/auth_provider.dart';
import 'package:park_smart/providers/location_provider.dart';
import 'package:park_smart/providers/parking_provider.dart';
import 'package:park_smart/screens/navigation_screen.dart';
import 'package:park_smart/screens/reservation_confirmation_screen.dart';

class ParkingLotDetailsScreen extends StatefulWidget {
  const ParkingLotDetailsScreen({super.key});

  @override
  State<ParkingLotDetailsScreen> createState() => _ParkingLotDetailsScreenState();
}

class _ParkingLotDetailsScreenState extends State<ParkingLotDetailsScreen> {
  bool _autoAssignSpot = true;

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final parkingLot = parkingProvider.selectedParkingLot;
    
    if (parkingLot == null) {
      return const Scaffold(
        body: Center(
          child: Text('No parking lot selected'),
        ),
      );
    }
    
    // Get available spots
    final availableSpots = parkingLot.spots.where((spot) => spot.isAvailable).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(parkingLot.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map showing the parking lot
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(parkingLot.latitude, parkingLot.longitude),
                  zoom: 17,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('lot_${parkingLot.id}'),
                    position: LatLng(parkingLot.latitude, parkingLot.longitude),
                    infoWindow: InfoWindow(
                      title: parkingLot.name,
                    ),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
            
            // Parking lot information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parkingLot.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    parkingLot.address,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoItem(
                        Icons.local_parking,
                        '${parkingLot.availableSpots}/${parkingLot.totalSpots}',
                        'Available Spots',
                      ),
                      _infoItem(
                        Icons.monetization_on,
                        '₹${parkingLot.pricePerHour}/hr',
                        'Price',
                      ),
                      _infoItem(
                        Icons.directions_car,
                        locationProvider.currentPosition != null
                            ? '${(locationProvider.calculateDistance(
                                locationProvider.currentLatLng,
                                LatLng(parkingLot.latitude, parkingLot.longitude),
                              ) / 1000).toStringAsFixed(1)} km'
                            : 'N/A',
                        'Distance',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Spot selection
                  Text(
                    'Select Parking Spot',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Auto-assign toggle
                  SwitchListTile(
                    title: const Text('Auto-assign nearest available spot'),
                    value: _autoAssignSpot,
                    onChanged: (value) {
                      setState(() {
                        _autoAssignSpot = value;
                        
                        // If turning on auto-assign, find the nearest spot
                        if (_autoAssignSpot && locationProvider.currentPosition != null) {
                          final nearestSpot = parkingProvider.findNearestAvailableSpot(
                            locationProvider.currentLatLng,
                          );
                          
                          if (nearestSpot != null) {
                            parkingProvider.selectParkingSpot(nearestSpot);
                          }
                        } else {
                          // Clear selected spot when turning off auto-assign
                          parkingProvider.selectParkingSpot(null);
                        }
                      });
                    },
                  ),
                  
                  if (!_autoAssignSpot) ...[
                    const SizedBox(height: 16),
                    
                    // Manual spot selection
                    if (availableSpots.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('No available spots in this parking lot'),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: availableSpots.length,
                        itemBuilder: (context, index) {
                          final spot = availableSpots[index];
                          final isSelected = parkingProvider.selectedParkingSpot?.id == spot.id;
                          
                          return GestureDetector(
                            onTap: () {
                              parkingProvider.selectParkingSpot(spot);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                spot.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Navigation and reservation buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NavigationScreen(
                                  destinationLatLng: LatLng(
                                    parkingLot.latitude,
                                    parkingLot.longitude,
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Navigate'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (parkingProvider.selectedParkingSpot != null || 
                                     (_autoAssignSpot && availableSpots.isNotEmpty))
                              ? () async {
                                  // If auto-assign is on and no spot is selected yet
                                  if (_autoAssignSpot && parkingProvider.selectedParkingSpot == null) {
                                    final nearestSpot = parkingProvider.findNearestAvailableSpot(
                                      locationProvider.currentLatLng,
                                    );
                                    
                                    if (nearestSpot != null) {
                                      parkingProvider.selectParkingSpot(nearestSpot);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No available spots found')),
                                      );
                                      return;
                                    }
                                  }
                                  
                                  // Create reservation
                                  final reservation = await parkingProvider.reserveParkingSpot(
                                    authProvider.user!.uid,
                                  );
                                  
                                  if (reservation != null && context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ReservationConfirmationScreen(
                                          reservation: reservation,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Reserve Spot'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

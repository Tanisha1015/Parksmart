// lib/providers/parking_provider.dart
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:park_smart/models/parking_lot.dart';
import 'package:park_smart/models/parking_spot.dart';
import 'package:park_smart/models/reservation.dart';
import 'package:uuid/uuid.dart';

class ParkingProvider with ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<ParkingLot> _parkingLots = [];
  List<Reservation> _reservationHistory = [];
  ParkingLot? _selectedParkingLot;
  ParkingSpot? _selectedParkingSpot;
  bool _isLoading = false;
  String _errorMessage = '';
  
  List<ParkingLot> get parkingLots => _parkingLots;
  List<Reservation> get reservationHistory => _reservationHistory;
  ParkingLot? get selectedParkingLot => _selectedParkingLot;
  ParkingSpot? get selectedParkingSpot => _selectedParkingSpot;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Fetch parking lots from Firebase
  Future<void> fetchParkingLots() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final snapshot = await _database.ref('parkingLots').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _parkingLots = [];
        
        data.forEach((key, value) {
          final lotData = value as Map<dynamic, dynamic>;
          
          // Convert spots data
          List<ParkingSpot> spots = [];
          if (lotData['spots'] != null) {
            final spotsData = lotData['spots'] as Map<dynamic, dynamic>;
            spotsData.forEach((spotKey, spotValue) {
              final spotData = spotValue as Map<dynamic, dynamic>;
              spots.add(ParkingSpot(
                id: spotKey.toString(),
                number: spotData['number'] ?? '',
                isAvailable: spotData['isAvailable'] ?? true,
                latitude: spotData['latitude'] ?? 0.0,
                longitude: spotData['longitude'] ?? 0.0,
              ));
            });
          }
          
          _parkingLots.add(ParkingLot(
            id: key.toString(),
            name: lotData['name'] ?? '',
            address: lotData['address'] ?? '',
            latitude: lotData['latitude'] ?? 0.0,
            longitude: lotData['longitude'] ?? 0.0,
            totalSpots: lotData['totalSpots'] ?? 0,
            availableSpots: lotData['availableSpots'] ?? 0,
            pricePerHour: lotData['pricePerHour'] ?? 0.0,
            spots: spots,
          ));
        });
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching parking lots: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Find nearby parking lots within a radius
  List<ParkingLot> findNearbyParkingLots(LatLng userLocation, double radiusInMeters) {
    return _parkingLots.where((lot) {
      final lotLocation = LatLng(lot.latitude, lot.longitude);
      final distance = _calculateDistance(userLocation, lotLocation);
      return distance <= radiusInMeters;
    }).toList();
  }
  
  // Calculate distance using Haversine formula
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(end.latitude - start.latitude);
    final double dLng = _toRadians(end.longitude - start.longitude);
    
    final double a = sin(dLat/2) * sin(dLat/2) +
                     cos(_toRadians(start.latitude)) * cos(_toRadians(end.latitude)) *
                     sin(dLng/2) * sin(dLng/2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return earthRadius * c; // in meters
  }
  
  double _toRadians(double degree) {
    return degree * pi / 180;
  }
  
  // Select parking lot
  void selectParkingLot(ParkingLot parkingLot) {
    _selectedParkingLot = parkingLot;
    _selectedParkingSpot = null;
    notifyListeners();
  }
  
  // Find the nearest available spot
  ParkingSpot? findNearestAvailableSpot(LatLng userLocation) {
    if (_selectedParkingLot == null || _selectedParkingLot!.spots.isEmpty) {
      return null;
    }
    
    ParkingSpot? nearestSpot;
    double minDistance = double.infinity;
    
    for (final spot in _selectedParkingLot!.spots) {
      if (spot.isAvailable) {
        final spotLocation = LatLng(spot.latitude, spot.longitude);
        final distance = _calculateDistance(userLocation, spotLocation);
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestSpot = spot;
        }
      }
    }
    
    return nearestSpot;
  }
  
  // Select parking spot
  void selectParkingSpot(ParkingSpot? parkingSpot) {
    _selectedParkingSpot = parkingSpot;
    notifyListeners();
  }
  
  // Reserve parking spot
  Future<Reservation?> reserveParkingSpot(String userId) async {
    if (_selectedParkingLot == null || _selectedParkingSpot == null) {
      _errorMessage = 'Please select a parking lot and spot first';
      notifyListeners();
      return null;
    }
    
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final String reservationId = const Uuid().v4();
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      
      final Reservation reservation = Reservation(
        id: reservationId,
        userId: userId,
        parkingLotId: _selectedParkingLot!.id,
        parkingLotName: _selectedParkingLot!.name,
        spotId: _selectedParkingSpot!.id,
        spotNumber: _selectedParkingSpot!.number,
        startTime: formattedDate,
        endTime: '',
        status: 'active',
        pricePerHour: _selectedParkingLot!.pricePerHour,
        totalAmount: 0.0,
      );
      
      // Update spot availability in Firebase
      await _database.ref('parkingLots/${_selectedParkingLot!.id}/spots/${_selectedParkingSpot!.id}')
        .update({'isAvailable': false});
      
      // Create reservation in Firebase
      await _database.ref('reservations/$reservationId').set(reservation.toJson());
      
      // Update available spots count
      await _database.ref('parkingLots/${_selectedParkingLot!.id}')
        .update({'availableSpots': _selectedParkingLot!.availableSpots - 1});
      
      // Update local data
      final updatedSpots = _selectedParkingLot!.spots.map((spot) {
        if (spot.id == _selectedParkingSpot!.id) {
          return spot.copyWith(isAvailable: false);
        }
        return spot;
      }).toList();
      
      _selectedParkingLot = _selectedParkingLot!.copyWith(
        availableSpots: _selectedParkingLot!.availableSpots - 1,
        spots: updatedSpots,
      );
      
      _selectedParkingSpot = _selectedParkingSpot!.copyWith(isAvailable: false);
      _reservationHistory.add(reservation);
      
      _isLoading = false;
      notifyListeners();
      return reservation;
    } catch (e) {
      _errorMessage = 'Error reserving parking spot: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Fetch user's reservation history
  Future<void> fetchReservationHistory(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final snapshot = await _database.ref('reservations')
        .orderByChild('userId')
        .equalTo(userId)
        .get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _reservationHistory = [];
        
        data.forEach((key, value) {
          final reservationData = value as Map<dynamic, dynamic>;
          _reservationHistory.add(Reservation(
            id: key.toString(),
            userId: reservationData['userId'] ?? '',
            parkingLotId: reservationData['parkingLotId'] ?? '',
            parkingLotName: reservationData['parkingLotName'] ?? '',
            spotId: reservationData['spotId'] ?? '',
            spotNumber: reservationData['spotNumber'] ?? '',
            startTime: reservationData['startTime'] ?? '',
            endTime: reservationData['endTime'] ?? '',
            status: reservationData['status'] ?? '',
            pricePerHour: reservationData['pricePerHour'] ?? 0.0,
            totalAmount: reservationData['totalAmount'] ?? 0.0,
          ));
        });
        
        // Sort by start time (most recent first)
        _reservationHistory.sort((a, b) => 
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime)
            .compareTo(DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime))
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching reservation history: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}

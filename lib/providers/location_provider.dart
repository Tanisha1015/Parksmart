// lib/providers/location_provider.dart
import 'dart:math' show cos, sqrt, asin, sin, pi, atan2;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String _errorMessage = '';
  
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  LatLng get currentLatLng => _currentPosition != null 
    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude) 
    : const LatLng(0, 0);
  
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied, we cannot request permissions.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentPosition = position;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error getting location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Calculate distance between two points using Haversine formula
  double calculateDistance(LatLng start, LatLng end) {
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
}

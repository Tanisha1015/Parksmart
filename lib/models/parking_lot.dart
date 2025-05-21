// lib/models/parking_lot.dart
import 'package:park_smart/models/parking_spot.dart';

class ParkingLot {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int totalSpots;
  final int availableSpots;
  final double pricePerHour;
  final List<ParkingSpot> spots;
  
  ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalSpots,
    required this.availableSpots,
    required this.pricePerHour,
    required this.spots,
  });
  
  ParkingLot copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? totalSpots,
    int? availableSpots,
    double? pricePerHour,
    List<ParkingSpot>? spots,
  }) {
    return ParkingLot(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalSpots: totalSpots ?? this.totalSpots,
      availableSpots: availableSpots ?? this.availableSpots,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      spots: spots ?? this.spots,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'totalSpots': totalSpots,
      'availableSpots': availableSpots,
      'pricePerHour': pricePerHour,
      'spots': spots.map((spot) => spot.toJson()).toList(),
    };
  }
}

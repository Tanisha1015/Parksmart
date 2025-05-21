// lib/models/parking_spot.dart
class ParkingSpot {
  final String id;
  final String number;
  final bool isAvailable;
  final double latitude;
  final double longitude;
  
  ParkingSpot({
    required this.id,
    required this.number,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
  });
  
  ParkingSpot copyWith({
    String? id,
    String? number,
    bool? isAvailable,
    double? latitude,
    double? longitude,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      number: number ?? this.number,
      isAvailable: isAvailable ?? this.isAvailable,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

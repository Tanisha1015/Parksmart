// lib/models/reservation.dart
class Reservation {
  final String id;
  final String userId;
  final String parkingLotId;
  final String parkingLotName;
  final String spotId;
  final String spotNumber;
  final String startTime;
  final String endTime;
  final String status;
  final double pricePerHour;
  final double totalAmount;
  
  Reservation({
    required this.id,
    required this.userId,
    required this.parkingLotId,
    required this.parkingLotName,
    required this.spotId,
    required this.spotNumber,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.pricePerHour,
    required this.totalAmount,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'parkingLotId': parkingLotId,
      'parkingLotName': parkingLotName,
      'spotId': spotId,
      'spotNumber': spotNumber,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'pricePerHour': pricePerHour,
      'totalAmount': totalAmount,
    };
  }
}

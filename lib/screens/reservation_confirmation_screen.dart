import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park_smart/models/reservation.dart';

class ReservationConfirmationScreen extends StatelessWidget {
  final Reservation reservation;

  const ReservationConfirmationScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final startTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(reservation.startTime);
    final formattedStartTime = DateFormat('MMM dd, yyyy - hh:mm a').format(startTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Your parking spot is reserved!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _infoRow('Parking Lot', reservation.parkingLotName),
                const SizedBox(height: 8),
                _infoRow('Spot Number', reservation.spotNumber),
                const SizedBox(height: 8),
                _infoRow('Start Time', formattedStartTime),
                const SizedBox(height: 8),
                _infoRow('Price per Hour', '₹${reservation.pricePerHour}'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

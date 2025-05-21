// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/models/reservation.dart';
import 'package:park_smart/providers/auth_provider.dart';
import 'package:park_smart/providers/parking_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<ParkingProvider>(context, listen: false)
            .fetchReservationHistory(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final reservations = parkingProvider.reservationHistory;
    
    if (parkingProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 72,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No reservation history yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _buildReservationCard(context, reservation);
      },
    );
  }
  
  Widget _buildReservationCard(BuildContext context, Reservation reservation) {
    final startTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(reservation.startTime);
    final formattedStartTime = DateFormat('MMM dd, yyyy - hh:mm a').format(startTime);
    
    Color statusColor;
    IconData statusIcon;
    
    switch (reservation.status) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.timer;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  reservation.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  formattedStartTime,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              reservation.parkingLotName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_parking, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Spot ${reservation.spotNumber}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('₹${reservation.pricePerHour}/hr'),
              ],
            ),
            if (reservation.status == 'completed' && reservation.totalAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.payment, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Total: ₹${reservation.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

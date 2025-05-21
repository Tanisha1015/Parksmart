// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/providers/auth_provider.dart';
import 'package:park_smart/providers/location_provider.dart';
import 'package:park_smart/providers/parking_provider.dart';
import 'package:park_smart/screens/auth_screen.dart';
import 'package:park_smart/screens/map_screen.dart';
import 'package:park_smart/screens/history_screen.dart';
import 'package:park_smart/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const MapScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Get user location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
      // Fetch parking lots
      Provider.of<ParkingProvider>(context, listen: false).fetchParkingLots();
      // Fetch user's reservation history
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<ParkingProvider>(context, listen: false)
            .fetchReservationHistory(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Park Smart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

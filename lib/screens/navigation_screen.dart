import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/providers/location_provider.dart';

class NavigationScreen extends StatefulWidget {
  final LatLng destinationLatLng;

  const NavigationScreen({
    super.key,
    required this.destinationLatLng,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // Removed: GoogleMapController? _mapController; (unused)
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = false;
  String _errorMessage = '';

  // Use this field in your API calls
  final String _googleApiKey = 'your_api_key';

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  Future<void> _getRoute() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);

      if (locationProvider.currentPosition == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to get current location';
        });
        return;
      }

      final origin = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );

      final destination = widget.destinationLatLng;

      PolylinePoints polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey, // Use the field here
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        Polyline polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        );

        setState(() {
          _polylines = {polyline};
        });
      } else {
        setState(() {
          _errorMessage = 'Unable to find a route';
        });
      }

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('origin'),
            position: origin,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            infoWindow: const InfoWindow(title: 'Parking Lot'),
          ),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error getting directions: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    if (locationProvider.currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation'),
        ),
        body: const Center(
          child: Text('Unable to get current location'),
        ),
      );
    }

    final origin = LatLng(
      locationProvider.currentPosition!.latitude,
      locationProvider.currentPosition!.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: origin,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              // Removed usage of _mapController since it's not used elsewhere

              LatLngBounds bounds = LatLngBounds(
                southwest: LatLng(
                  origin.latitude < widget.destinationLatLng.latitude
                      ? origin.latitude
                      : widget.destinationLatLng.latitude,
                  origin.longitude < widget.destinationLatLng.longitude
                      ? origin.longitude
                      : widget.destinationLatLng.longitude,
                ),
                northeast: LatLng(
                  origin.latitude > widget.destinationLatLng.latitude
                      ? origin.latitude
                      : widget.destinationLatLng.latitude,
                  origin.longitude > widget.destinationLatLng.longitude
                      ? origin.longitude
                      : widget.destinationLatLng.longitude,
                ),
              );

              controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
            },
          ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
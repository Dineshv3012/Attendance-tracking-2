
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Haversine distance in meters
  static double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    var R = 6371000; // meters
    var dLat = _deg2rad(lat2 - lat1);
    var dLon = _deg2rad(lon2 - lon1);
    var a = 
      (sin(dLat/2) * sin(dLat/2)) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
      (sin(dLon/2) * sin(dLon/2)); 
    var c = 2 * atan2(sqrt(a), sqrt(1-a)); 
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (3.1415926535 / 180.0);
}


import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'location_service.dart';

class AttendanceService {
  static Future<String> markAttendance({required String photoPath, required double lat, required double lng}) async {
    // Enforce geofence (example: 200m around HQ)
    const allowedLat = 12.9716;
    const allowedLng = 77.5946;
    const radiusMeters = 300.0;

    final distance = LocationService.distanceMeters(lat, lng, allowedLat, allowedLng);
    if (distance > radiusMeters) {
      throw Exception('Outside allowed geofence (${distance.toStringAsFixed(0)}m away)');
    }

    final user = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now().toUtc();
    final dayId = DateFormat('yyyy-MM-dd').format(now);

    // Upload selfie to Storage
    final ref = FirebaseStorage.instance.ref('selfies/${user.uid}/$dayId-${now.millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(photoPath));
    final selfieUrl = await ref.getDownloadURL();

    // Decide check-in vs check-out
    final today = await FirebaseFirestore.instance.collection('attendance')
      .where('uid', isEqualTo: user.uid)
      .where('dayId', isEqualTo: dayId)
      .get();

    final type = today.docs.any((d) => d['type'] == 'check-in') && !today.docs.any((d) => d['type'] == 'check-out')
      ? 'check-out' : 'check-in';

    await FirebaseFirestore.instance.collection('attendance').add({
      'uid': user.uid,
      'userEmail': user.email,
      'type': type,
      'timestamp': now,
      'dayId': dayId,
      'lat': lat,
      'lng': lng,
      'selfieUrl': selfieUrl,
      'locationName': 'HQ',
    });

    return 'Marked $type successfully';
  }
}

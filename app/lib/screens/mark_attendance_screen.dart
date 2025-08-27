
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../services/attendance_service.dart';
import '../services/location_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  CameraController? _controller;
  XFile? _photo;
  bool loading = false;
  String? status;
  Position? _pos;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final cams = await availableCameras();
      _controller = CameraController(cams.first, ResolutionPreset.medium, enableAudio: false);
      await _controller!.initialize();
      _pos = await LocationService.getPosition();
      if (mounted) setState(() {});
    } on CameraException catch (e) {
      setState(() { status = e.description; });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canMark = _pos != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: CameraPreview(_controller!))
            else
              const Expanded(child: Center(child: CircularProgressIndicator())),
            const SizedBox(height: 12),
            if (status != null) Text(status!, style: const TextStyle(color: Colors.red)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canMark ? () async {
                      setState(() { loading = true; status = null; });
                      try {
                        _photo = await _controller!.takePicture();
                        final res = await AttendanceService.markAttendance(
                          photoPath: _photo!.path,
                          lat: _pos!.latitude,
                          lng: _pos!.longitude,
                        );
                        setState(() { status = res; });
                      } catch (e) {
                        setState(() { status = e.toString(); });
                      } finally {
                        setState(() { loading = false; });
                      }
                    } : null,
                    icon: const Icon(Icons.login),
                    label: Text(loading ? 'Marking...' : 'Check In / Out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

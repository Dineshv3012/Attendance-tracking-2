
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(radius: 32, backgroundImage: u.photoURL != null ? NetworkImage(u.photoURL!) : null, child: u.photoURL == null ? const Icon(Icons.person) : null),
              const SizedBox(width: 12),
              Expanded(child: Text(u.email ?? u.uid, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 16),
            Text('UID: ${u.uid}'),
          ],
        ),
      ),
    );
  }
}

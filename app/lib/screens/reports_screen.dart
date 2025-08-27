
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 1),
                      initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
                    );
                    if (picked != null) setState(() => range = picked);
                  },
                  child: Text(range == null ? 'Pick Range' : '${DateFormat.yMMMd().format(range!.start)} - ${DateFormat.yMMMd().format(range!.end)}'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('attendance')
                .where('timestamp', isGreaterThanOrEqualTo: (range?.start ?? DateTime.now().subtract(const Duration(days: 7))).toUtc())
                .where('timestamp', isLessThanOrEqualTo: (range?.end ?? DateTime.now()).toUtc())
                .orderBy('timestamp', descending: true)
                .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No records'));
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final ts = (d['timestamp'] as Timestamp).toDate().toLocal();
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text('${d['userEmail']} • ${d['type']}'),
                      subtitle: Text('${DateFormat.yMMMd().add_jm().format(ts)}  •  ${d['locationName'] ?? 'Unknown'}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/medicine_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'add_edit_medicine_screen.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;
  const MedicineDetailsScreen({super.key, required this.medicine});

  Future<void> _deleteMedicine(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Medicine?'),
        content: const Text('This will also cancel the scheduled alarms.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);

      // 1. Cancel Alarms
      for (var id in medicine.notificationIds) {
        await notificationService.cancelNotification(id);
      }
      // 2. Delete from DB
      await firestoreService.deleteMedicine(medicine.id);
      
      if(context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AddEditMedicineScreen(medicine: medicine)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteMedicine(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medicine.name, style: Theme.of(context).textTheme.headlineMedium),
            const Divider(),
            const SizedBox(height: 10),
            _detailRow(Icons.medical_services, "Dosage", medicine.dosage),
            _detailRow(Icons.repeat, "Frequency", medicine.frequency),
            _detailRow(Icons.alarm, "Time", DateFormat.jm().format(medicine.startTime)),
            const SizedBox(height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.teal),
                    SizedBox(width: 10),
                    Text("Alarm is Active", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }
}
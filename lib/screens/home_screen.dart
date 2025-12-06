import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine_model.dart';
import '../services/firestore_service.dart';
import 'add_edit_medicine_screen.dart';
import 'medicine_details_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediTrack Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: firestoreService.getMedicines(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading data"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final medicines = snapshot.data ?? [];

          if (medicines.isEmpty) {
            return const Center(child: Text("No medicines added yet."));
          }

          return ListView.builder(
            itemCount: medicines.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.medication, color: Colors.teal),
                  ),
                  title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${medicine.dosage} - ${DateFormat.jm().format(medicine.startTime)}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicineDetailsScreen(medicine: medicine),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditMedicineScreen()),
          );
        },
        label: const Text("Add Medicine"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
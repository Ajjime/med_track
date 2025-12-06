import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/medicine_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name ?? '');
    _dosageController = TextEditingController(text: widget.medicine?.dosage ?? '');
    if (widget.medicine != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.medicine!.startTime);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    // 1. Generate ID and Dates
    final String id = widget.medicine?.id ?? const Uuid().v4();
    final DateTime now = DateTime.now();
    final DateTime scheduledDateTime = DateTime(
      now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute
    );

    // 2. Handle Notifications
    // If editing, cancel old notification
    if (widget.medicine != null && widget.medicine!.notificationIds.isNotEmpty) {
       for(var notifId in widget.medicine!.notificationIds) {
         await notificationService.cancelNotification(notifId);
       }
    }

    // Schedule new Notification
    final int newNotificationId = Random().nextInt(1000000); // Simple random ID
    await notificationService.scheduleDailyNotification(
      id: newNotificationId,
      title: 'Time for ${_nameController.text}',
      body: 'Take ${_dosageController.text}',
      time: scheduledDateTime,
    );

    // 3. Save to Firestore
    final newMedicine = Medicine(
      id: id,
      name: _nameController.text,
      dosage: _dosageController.text,
      frequency: "Daily", // Default for this simplified version
      startTime: scheduledDateTime,
      notificationIds: [newNotificationId],
    );

    if (widget.medicine == null) {
      await firestoreService.addMedicine(newMedicine);
    } else {
      await firestoreService.updateMedicine(newMedicine);
    }

    setState(() => _isLoading = false);
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medicine != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage (e.g., 500mg)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter dosage' : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text("Reminder Time: ${_selectedTime.format(context)}"),
                trailing: const Icon(Icons.alarm),
                tileColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: _pickTime,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveMedicine,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white
                      ),
                      child: Text(isEditing ? 'Update Schedule' : 'Save & Set Alarm'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class FirestoreService {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('medicines');

  // Create
  Future<void> addMedicine(Medicine medicine) {
    return _db.doc(medicine.id).set(medicine.toMap());
  }

  // Read
  Stream<List<Medicine>> getMedicines() {
    return _db.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // Update
  Future<void> updateMedicine(Medicine medicine) {
    return _db.doc(medicine.id).update(medicine.toMap());
  }

  // Delete
  Future<void> deleteMedicine(String id) {
    return _db.doc(id).delete();
  }
}
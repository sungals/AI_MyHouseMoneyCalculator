import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/calculation_history.dart';

class CalculationHistoryRemoteStore {
  CalculationHistoryRemoteStore({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  FirebaseAuth get _safeAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _safeFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final userId = _safeAuth.currentUser?.uid;
    if (userId == null) return null;
    return _safeFirestore
        .collection('users')
        .doc(userId)
        .collection('calculation_history');
  }

  Future<List<CalculationHistory>> fetchAll() async {
    final collection = _collection;
    if (collection == null) return [];

    final snapshot =
        await collection.orderBy('created_at', descending: true).get();

    return snapshot.docs
        .map((doc) => CalculationHistory.fromRemoteJson(doc.data()))
        .toList();
  }

  Future<void> upsert(CalculationHistory history) async {
    final collection = _collection;
    if (collection == null) return;

    await collection.doc(history.id).set(
          history.toRemoteJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> upsertMany(List<CalculationHistory> items) async {
    final collection = _collection;
    if (collection == null || items.isEmpty) return;

    final batch = _safeFirestore.batch();
    for (final item in items.where((h) => !h.isDeleted)) {
      batch.set(
        collection.doc(item.id),
        item.toRemoteJson(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> delete(String id) async {
    final collection = _collection;
    if (collection == null) return;

    await collection.doc(id).delete();
  }
}

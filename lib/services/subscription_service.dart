import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionService {
  final _db = FirebaseFirestore.instance;

  /// Adds a subscription and links it to the user (atomic).
  Future<String> addSubscription({
    required String userId,
    required Map<String, dynamic> subscriptionData, // should NOT include id
  }) async {
    final batch = _db.batch();
    final col = _db.collection('subscriptions');
    final newDocRef = col.doc(); // auto id

    // ensure subscriptionData includes userId
    final docData = {
      ...subscriptionData,
      'userId': userId,
      'createdAtUtc': FieldValue.serverTimestamp(),
      'updatedAtUtc': FieldValue.serverTimestamp(),
    };

    batch.set(newDocRef, docData);

    final userDoc = _db.collection('users').doc(userId);
    batch.update(userDoc, {
      'subscriptionIds': FieldValue.arrayUnion([newDocRef.id]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return newDocRef.id;
  }

  /// Removes subscription and removes reference from user doc (atomic).
  Future<void> removeSubscription({
    required String userId,
    required String subscriptionId,
  }) async {
    final batch = _db.batch();
    final subDoc = _db.collection('subscriptions').doc(subscriptionId);
    batch.delete(subDoc);

    final userDoc = _db.collection('users').doc(userId);
    batch.update(userDoc, {
      'subscriptionIds': FieldValue.arrayRemove([subscriptionId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Update subscription doc (does not touch user index)
  Future<void> updateSubscription({
    required String subscriptionId,
    required Map<String, dynamic> patch,
  }) async {
    final doc = _db.collection('subscriptions').doc(subscriptionId);
    await doc.update({...patch, 'updatedAtUtc': FieldValue.serverTimestamp()});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/app_models.dart';

class ComplaintsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ComplaintThread>> watchAll(String societyId) {
    return _firestore
        .collection('threads')
        .where('societyId', isEqualTo: societyId)
        .where('type', isEqualTo: 'COMPLAINT')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintThread.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> createComplaint({
    required String societyId,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
  }) async {
    await _firestore.collection('threads').doc().set({
      'societyId': societyId,
      'ownerId': authorId,
      'ownerName': authorName,
      'type': 'COMPLAINT',
      'title': title,
      'description': description,
      'complaintStatus': 'OPEN',
      'postCount': 0,
      'hasPolls': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

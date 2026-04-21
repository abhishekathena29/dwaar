import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/app_models.dart';

class CommitteeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CommitteeMember>> watchAll(String societyId) {
    return _firestore
        .collection('memberships')
        .where('societyId', isEqualTo: societyId)
        .limit(200)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommitteeMember.fromMap(doc.id, doc.data()))
            .toList());
  }
}

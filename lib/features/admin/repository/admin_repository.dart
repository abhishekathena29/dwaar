import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/app_models.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Stream<List<MembershipRequest>> watchPendingRequests(String societyId) {
    return _firestore
        .collection('membership_requests')
        .where('societyId', isEqualTo: societyId)
        .where('status', isEqualTo: 'PENDING')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MembershipRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> approve(MembershipRequest request) async {
    final batch = _firestore.batch();
    batch.update(
      _firestore.collection('membership_requests').doc(request.id),
      {'status': 'APPROVED', 'updatedAt': FieldValue.serverTimestamp()},
    );
    final membershipId = _uuid.v4();
    batch.set(
      _firestore.collection('memberships').doc(membershipId),
      {
        'userId': request.userId,
        'societyId': request.societyId,
        'societyName': request.societyName,
        'societyCode': '',
        'flatNumber': request.flatNumber,
        'wing': request.wing,
        'floor': request.floor,
        'name': request.userName,
        'role': 'RESIDENT',
        'status': 'ACTIVE',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
  }

  Future<void> reject(String requestId) async {
    await _firestore.collection('membership_requests').doc(requestId).update({
      'status': 'REJECTED',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

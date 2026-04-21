import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/app_models.dart';

class EventsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<EventItem>> watchAll(String societyId) {
    return _firestore
        .collection('threads')
        .where('societyId', isEqualTo: societyId)
        .where('type', isEqualTo: 'EVENT')
        .orderBy('eventDate', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<EventItem> fetchDetail(String threadId) async {
    final doc = await _firestore.collection('threads').doc(threadId).get();
    return EventItem.fromMap(doc.id, doc.data() ?? const {});
  }

  Future<void> createEvent({
    required String societyId,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required DateTime eventDate,
    required String location,
  }) async {
    await _firestore.collection('threads').doc().set({
      'societyId': societyId,
      'ownerId': authorId,
      'ownerName': authorName,
      'type': 'EVENT',
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventLocation': location,
      'goingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRsvp({
    required String threadId,
    required String userId,
    required String status,
  }) async {
    final rsvpId = '$threadId-$userId';
    await _firestore.collection('event_rsvps').doc(rsvpId).set({
      'threadId': threadId,
      'userId': userId,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('threads').doc(threadId).set({
      'userRsvp': status,
    }, SetOptions(merge: true));
  }
}

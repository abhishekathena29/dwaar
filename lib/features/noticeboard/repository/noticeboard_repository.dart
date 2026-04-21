import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/app_models.dart';

class NoticeboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FeedPost>> watchAll(String societyId) {
    return _firestore
        .collection('posts')
        .where('societyId', isEqualTo: societyId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<ThreadDetail> fetchThreadDetail(String threadId) async {
    final threadDoc =
        await _firestore.collection('threads').doc(threadId).get();
    final postsSnapshot = await _firestore
        .collection('posts')
        .where('threadId', isEqualTo: threadId)
        .orderBy('createdAt')
        .get();
    final pollsSnapshot = await _firestore
        .collection('polls')
        .where('threadId', isEqualTo: threadId)
        .get();
    final posts = postsSnapshot.docs
        .map((doc) => FeedPost.fromMap(doc.id, doc.data()))
        .toList();
    final polls = pollsSnapshot.docs
        .map((doc) => PollItem.fromMap(doc.id, doc.data()))
        .toList();
    return ThreadDetail.fromMap(
      threadDoc.id,
      threadDoc.data() ?? const {},
      posts: posts,
      polls: polls,
    );
  }

  Future<void> createPost({
    required String societyId,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    required String postType,
  }) async {
    final threadRef = _firestore.collection('threads').doc();
    final postRef = _firestore.collection('posts').doc();
    await threadRef.set({
      'societyId': societyId,
      'ownerId': authorId,
      'ownerName': authorName,
      'type': 'NOTICEBOARD',
      'title': title,
      'description': content,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'OPEN',
    });
    await postRef.set({
      'societyId': societyId,
      'threadId': threadRef.id,
      'threadTitle': title,
      'content': content,
      'postType': postType,
      'author': {'id': authorId, 'name': authorName},
      'reactionCounts': {'LIKE': 0},
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'isPinned': false,
      'imageUrls': const [],
    });
  }

  Future<void> addThreadMessage({
    required String threadId,
    required String societyId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    await _firestore.collection('posts').doc().set({
      'societyId': societyId,
      'threadId': threadId,
      'threadTitle': '',
      'content': content,
      'postType': 'GENERAL',
      'author': {'id': authorId, 'name': authorName},
      'reactionCounts': {'LIKE': 0},
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrls': const [],
    });
  }
}

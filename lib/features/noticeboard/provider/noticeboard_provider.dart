import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../auth/provider/auth_provider.dart';
import '../repository/noticeboard_repository.dart';

class NoticeboardProvider extends ChangeNotifier {
  NoticeboardProvider({
    required this.repository,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider;

  final NoticeboardRepository repository;
  AuthProvider _authProvider;

  StreamSubscription<List<FeedPost>>? _subscription;

  List<FeedPost> _allPosts = [];
  String activeSection = 'all';

  static const Map<String, List<String>> sections = {
    'all': [],
    'announcements': ['ANNOUNCEMENT', 'EMERGENCY', 'SAFETY_ALERT'],
    'marketplace': ['BUY_SELL', 'RENT', 'GIVEAWAY', 'RECOMMENDATION'],
    'community': [
      'HOBBY',
      'EVENT_INVITE',
      'PET_CORNER',
      'CARPOOL',
      'SKILL_SHARE',
    ],
    'civic': ['CIVIC_ISSUE', 'NOISE_COMPLAINT', 'PARKING_ISSUE'],
    'alerts': [
      'LOST_FOUND',
      'PACKAGE_ALERT',
      'VISITOR_NOTIFICATION',
      'HELP_NEEDED',
    ],
    'general': ['GENERAL', 'DISCUSSION', 'POLL'],
  };

  List<FeedPost> get posts {
    final types = sections[activeSection];
    if (types == null || types.isEmpty) return _allPosts;
    return _allPosts.where((p) => types.contains(p.postType)).toList();
  }

  String? get _societyId => _authProvider.membership?.societyId;

  void bindAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_societyId != null) load();
  }

  void load() {
    if (_societyId == null) return;
    _subscription?.cancel();
    _subscription = repository.watchAll(_societyId!).listen((items) {
      _allPosts = items;
      notifyListeners();
    });
  }

  void setSection(String section) {
    activeSection = section;
    notifyListeners();
  }

  Future<ThreadDetail> fetchThreadDetail(String threadId) {
    return repository.fetchThreadDetail(threadId);
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String postType,
  }) async {
    final user = _authProvider.profile;
    if (user == null || _societyId == null) return;
    await repository.createPost(
      societyId: _societyId!,
      authorId: user.id,
      authorName: user.displayName ?? user.anonymousUsername ?? 'Resident',
      title: title,
      content: content,
      postType: postType,
    );
  }

  Future<void> sendThreadMessage({
    required String threadId,
    required String content,
  }) async {
    final user = _authProvider.profile;
    if (user == null || _societyId == null) return;
    await repository.addThreadMessage(
      threadId: threadId,
      societyId: _societyId!,
      authorId: user.id,
      authorName: user.displayName ?? user.anonymousUsername ?? 'Resident',
      content: content,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../auth/provider/auth_provider.dart';
import '../repository/events_repository.dart';

class EventsProvider extends ChangeNotifier {
  EventsProvider({
    required this.repository,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider;

  final EventsRepository repository;
  AuthProvider _authProvider;

  StreamSubscription<List<EventItem>>? _subscription;

  List<EventItem> _allEvents = [];
  bool pastOnly = false;

  List<EventItem> get events {
    return _allEvents.where((e) => e.isPast == pastOnly).toList();
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
      _allEvents = items;
      notifyListeners();
    });
  }

  void setMode(bool past) {
    pastOnly = past;
    notifyListeners();
  }

  Future<EventItem> fetchDetail(String threadId) {
    return repository.fetchDetail(threadId);
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
  }) async {
    final user = _authProvider.profile;
    if (user == null || _societyId == null) return;
    await repository.createEvent(
      societyId: _societyId!,
      authorId: user.id,
      authorName: user.displayName ?? user.anonymousUsername ?? 'Resident',
      title: title,
      description: description,
      eventDate: date,
      location: location,
    );
  }

  Future<void> updateRsvp({
    required String threadId,
    required String status,
  }) async {
    final user = _authProvider.profile;
    if (user == null) return;
    await repository.updateRsvp(
      threadId: threadId,
      userId: user.id,
      status: status,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

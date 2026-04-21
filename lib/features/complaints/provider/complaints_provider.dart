import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../auth/provider/auth_provider.dart';
import '../repository/complaints_repository.dart';

class ComplaintsProvider extends ChangeNotifier {
  ComplaintsProvider({
    required this.repository,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider;

  final ComplaintsRepository repository;
  AuthProvider _authProvider;

  StreamSubscription<List<ComplaintThread>>? _subscription;

  List<ComplaintThread> _allComplaints = [];
  bool resolvedOnly = false;

  List<ComplaintThread> get complaints {
    if (resolvedOnly) {
      return _allComplaints.where((c) => c.status == 'RESOLVED').toList();
    }
    return _allComplaints.where((c) => c.status != 'RESOLVED').toList();
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
      _allComplaints = items;
      notifyListeners();
    });
  }

  void setMode(bool resolved) {
    resolvedOnly = resolved;
    notifyListeners();
  }

  Future<void> createComplaint({
    required String title,
    required String description,
  }) async {
    final user = _authProvider.profile;
    if (user == null || _societyId == null) return;
    await repository.createComplaint(
      societyId: _societyId!,
      authorId: user.id,
      authorName: user.displayName ?? user.anonymousUsername ?? 'Resident',
      title: title,
      description: description,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../auth/provider/auth_provider.dart';
import '../repository/committee_repository.dart';

class CommitteeProvider extends ChangeNotifier {
  CommitteeProvider({
    required this.repository,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider;

  final CommitteeRepository repository;
  AuthProvider _authProvider;

  StreamSubscription<List<CommitteeMember>>? _subscription;

  List<CommitteeMember> _allMembers = [];

  static const _committeeRoles = [
    'COMMITTEE_MEMBER',
    'SECRETARY',
    'CHAIRMAN',
    'ADMIN',
  ];

  List<CommitteeMember> get members {
    return _allMembers
        .where((m) => _committeeRoles.contains(m.role))
        .toList();
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
      _allMembers = items;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

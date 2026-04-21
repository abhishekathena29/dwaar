import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../auth/provider/auth_provider.dart';
import '../repository/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({
    required this.repository,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider;

  final AdminRepository repository;
  AuthProvider _authProvider;

  StreamSubscription<List<MembershipRequest>>? _subscription;

  List<MembershipRequest> pendingRequests = [];

  int get pendingCount => pendingRequests.length;

  String? get _societyId => _authProvider.membership?.societyId;

  bool get isAdmin {
    final role = _authProvider.membership?.role;
    return role == 'ADMIN' || role == 'CHAIRMAN' || role == 'SECRETARY';
  }

  void bindAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_societyId != null && isAdmin) load();
  }

  void load() {
    if (_societyId == null || !isAdmin) return;
    _subscription?.cancel();
    _subscription =
        repository.watchPendingRequests(_societyId!).listen((items) {
      pendingRequests = items;
      notifyListeners();
    });
  }

  Future<void> approve(MembershipRequest request) async {
    await repository.approve(request);
  }

  Future<void> reject(String requestId) async {
    await repository.reject(requestId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

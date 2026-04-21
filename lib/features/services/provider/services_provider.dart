import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../../auth/provider/auth_provider.dart';
import '../repository/services_repository.dart';

class ServicesProvider extends ChangeNotifier {
  ServicesProvider({
    required this.repository,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider;

  final ServicesRepository repository;
  AuthProvider _authProvider;

  StreamSubscription<List<ServiceItem>>? _subscription;

  List<ServiceItem> _allServices = [];
  String searchQuery = '';
  String? selectedCategory;

  List<ServiceItem> get services {
    var result = _allServices;
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      result = result.where((s) => s.category == selectedCategory).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.contactName.toLowerCase().contains(q))
          .toList();
    }
    return result;
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
      _allServices = items;
      notifyListeners();
    });
  }

  void setFilters({String? category, String? query}) {
    selectedCategory = category;
    if (query != null) searchQuery = query;
    notifyListeners();
  }

  Future<ServiceItem> fetchDetail(String serviceId) {
    return repository.fetchDetail(serviceId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

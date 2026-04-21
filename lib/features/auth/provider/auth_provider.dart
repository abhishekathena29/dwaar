import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/app_models.dart';
import '../repository/auth_repository.dart';
import '../repository/society_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this.authRepository,
    required this.societyRepository,
  });

  final AuthRepository authRepository;
  final SocietyRepository societyRepository;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<SocietyMembership?>? _membershipSubscription;

  bool isLoading = true;
  bool isAuthenticated = false;
  String? verificationId;
  int resendTimer = 0;
  UserProfile? profile;
  SocietyMembership? membership;

  bool get hasCompletedProfile => profile?.onboardingComplete ?? false;
  bool get hasMembership => membership != null;

  Future<void> initialize() async {
    _authSubscription = authRepository.authStateChanges().listen((user) async {
      isAuthenticated = user != null;
      if (user == null) {
        profile = null;
        membership = null;
        _membershipSubscription?.cancel();
        isLoading = false;
        notifyListeners();
        return;
      }
      profile =
          await authRepository.fetchProfile(user.uid) ??
          UserProfile(
            id: user.uid,
            phoneNumber: user.phoneNumber?.replaceFirst('+91', '') ?? '',
            isPhoneVerified: user.phoneNumber != null,
          );
      _membershipSubscription?.cancel();
      _membershipSubscription = societyRepository
          .watchMembership(user.uid)
          .listen((data) {
            membership = data;
            notifyListeners();
          });
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendOtp(String phoneNumber) async {
    await authRepository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (id, _) {
        verificationId = id;
        resendTimer = 30;
        _tickTimer();
        notifyListeners();
      },
      onFailed: (error) => throw error,
    );
  }

  void _tickTimer() {
    Future.doWhile(() async {
      if (resendTimer <= 0) return false;
      await Future<void>.delayed(const Duration(seconds: 1));
      resendTimer -= 1;
      notifyListeners();
      return resendTimer > 0;
    });
  }

  Future<void> verifyOtp(String code) async {
    if (verificationId == null) {
      throw Exception('Verification session expired. Request OTP again.');
    }
    await authRepository.verifyOtp(
      verificationId: verificationId!,
      smsCode: code,
    );
  }

  Future<void> saveProfile({
    required String displayName,
    required String anonymousUsername,
  }) async {
    final user = authRepository.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final updated = UserProfile(
      id: user.uid,
      phoneNumber: user.phoneNumber?.replaceFirst('+91', '') ?? '',
      displayName: displayName,
      anonymousUsername: anonymousUsername,
      avatarUrl: profile?.avatarUrl,
      isPhoneVerified: true,
      onboardingComplete: true,
    );
    await authRepository.createOrUpdateProfile(updated);
    profile = updated;
    notifyListeners();
  }

  Future<void> createSociety({
    required String name,
    required String code,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required int totalFlats,
    required String flatNumber,
    String? wing,
    int? floor,
  }) async {
    final user = authRepository.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final existing = await societyRepository.lookupSocietyByCode(code);
    if (existing != null) {
      throw Exception('A society with this code already exists');
    }
    final society = await societyRepository.createSociety(
      name: name,
      code: code,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      totalFlats: totalFlats,
      createdBy: user.uid,
    );
    await societyRepository.createActiveMembership(
      userId: user.uid,
      society: society,
      flatNumber: flatNumber,
      role: 'ADMIN',
      wing: wing,
      floor: floor,
      displayName: profile?.displayName,
    );
  }

  Future<void> joinSociety({
    required Society society,
    required String flatNumber,
    String? wing,
    int? floor,
  }) async {
    final user = authRepository.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await societyRepository.createMembershipRequest(
      userId: user.uid,
      society: society,
      flatNumber: flatNumber,
      wing: wing,
      floor: floor,
      userName: profile?.displayName,
      userPhone: profile?.phoneNumber,
    );
  }

  Future<void> logout() => authRepository.signOut();

  @override
  void dispose() {
    _authSubscription?.cancel();
    _membershipSubscription?.cancel();
    super.dispose();
  }
}

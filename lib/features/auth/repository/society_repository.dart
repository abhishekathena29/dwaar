import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/app_models.dart';

class SocietyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Stream<SocietyMembership?> watchMembership(String userId) {
    return _firestore
        .collection('memberships')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ACTIVE')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return SocietyMembership.fromMap(doc.id, doc.data());
        });
  }

  Future<Society?> lookupSocietyByCode(String code) async {
    final snapshot = await _firestore
        .collection('societies')
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Society.fromMap(doc.id, doc.data());
  }

  Future<List<Society>> listSocieties() async {
    final snapshot = await _firestore
        .collection('societies')
        .orderBy('name')
        .limit(100)
        .get();
    return snapshot.docs
        .map((doc) => Society.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Society> createSociety({
    required String name,
    required String code,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required int totalFlats,
    required String createdBy,
  }) async {
    final docRef = await _firestore.collection('societies').add({
      'name': name,
      'code': code.trim().toUpperCase(),
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'totalFlats': totalFlats,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return Society(
      id: docRef.id,
      name: name,
      code: code.trim().toUpperCase(),
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      totalFlats: totalFlats,
      createdBy: createdBy,
    );
  }

  Future<void> createActiveMembership({
    required String userId,
    required Society society,
    required String flatNumber,
    required String role,
    String? wing,
    int? floor,
    String? displayName,
  }) async {
    final membershipId = _uuid.v4();
    await _firestore.collection('memberships').doc(membershipId).set({
      'userId': userId,
      'societyId': society.id,
      'societyName': society.name,
      'societyCode': society.code,
      'flatNumber': flatNumber,
      'role': role,
      'wing': wing,
      'floor': floor,
      'name': displayName,
      'status': 'ACTIVE',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createMembershipRequest({
    required String userId,
    required Society society,
    required String flatNumber,
    String? wing,
    int? floor,
    String? userName,
    String? userPhone,
  }) async {
    final requestId = _uuid.v4();
    await _firestore.collection('membership_requests').doc(requestId).set({
      'userId': userId,
      'societyId': society.id,
      'societyName': society.name,
      'societyCode': society.code,
      'flatNumber': flatNumber,
      'wing': wing,
      'floor': floor,
      'userName': userName,
      'userPhone': userPhone,
      'status': 'PENDING',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

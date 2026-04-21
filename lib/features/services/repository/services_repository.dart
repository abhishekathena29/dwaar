import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/app_models.dart';

class ServicesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ServiceItem>> watchAll(String societyId) {
    return _firestore
        .collection('services')
        .where('societyId', isEqualTo: societyId)
        .orderBy('name')
        .limit(200)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<ServiceItem> fetchDetail(String serviceId) async {
    final doc = await _firestore.collection('services').doc(serviceId).get();
    return ServiceItem.fromMap(doc.id, doc.data() ?? const {});
  }
}

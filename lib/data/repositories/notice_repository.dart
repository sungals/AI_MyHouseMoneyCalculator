import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notice.dart';

class NoticeRepository {
  NoticeRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notices =>
      _firestore.collection('notices');

  CollectionReference<Map<String, dynamic>>? get _readNotices {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('notice_reads');
  }

  Future<List<Notice>> fetchNotices() async {
    final snapshot = await _notices
        .where('is_published', isEqualTo: true)
        .orderBy('published_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Notice.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  Future<Notice?> fetchNoticeById(String id) async {
    final doc = await _notices.doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    final notice = Notice.fromJson(data, id: doc.id);
    if (!notice.isPublished) return null;
    return notice;
  }

  Future<Notice?> fetchNoticeByIdForAdmin(String id) async {
    final doc = await _notices.doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return Notice.fromJson(data, id: doc.id);
  }

  Future<Set<String>> fetchReadNoticeIds() async {
    final readNotices = _readNotices;
    if (readNotices == null) return {};

    final snapshot = await readNotices.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> markAsRead(String noticeId) async {
    final readNotices = _readNotices;
    if (readNotices == null) return;

    await readNotices.doc(noticeId).set({
      'notice_id': noticeId,
      'read_at': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Stream<List<Notice>> watchNotices() {
    return _notices
        .where('is_published', isEqualTo: true)
        .orderBy('published_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Notice.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<List<Notice>> fetchAllNoticesForAdmin() async {
    final snapshot = await _notices
        .orderBy('published_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Notice.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  Future<void> createNotice({
    required String title,
    required String body,
    String? contentHtml,
    required DateTime publishedAt,
    required bool isPublished,
  }) async {
    final doc = _notices.doc();
    await doc.set({
      'id': doc.id,
      'title': title,
      'body': body,
      'content_html': contentHtml,
      'published_at': publishedAt.toUtc().toIso8601String(),
      'is_published': isPublished,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> updateNotice({
    required String id,
    required String title,
    required String body,
    String? contentHtml,
    required DateTime publishedAt,
    required bool isPublished,
  }) async {
    await _notices.doc(id).set({
      'id': id,
      'title': title,
      'body': body,
      'content_html': contentHtml,
      'published_at': publishedAt.toUtc().toIso8601String(),
      'is_published': isPublished,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteNotice(String id) async {
    await _notices.doc(id).delete();
  }
}

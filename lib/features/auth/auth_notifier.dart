import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/calculation_history_repository.dart';
import '../../providers/calculation_history_provider.dart';
import '../../core/notifications/firebase_push_service.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AppAuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore? _firestore;
  final CalculationHistoryRepository _repo;
  final Future<void> Function()? _beforeSignOut;
  final Future<void> Function(String userId)? _deleteRemoteData;

  AuthNotifier({
    required FirebaseAuth auth,
    FirebaseFirestore? firestore,
    required CalculationHistoryRepository repo,
    Future<void> Function()? beforeSignOut,
    Future<void> Function(String userId)? deleteRemoteData,
  })  : _auth = auth,
        _firestore = firestore,
        _repo = repo,
        _beforeSignOut = beforeSignOut,
        _deleteRemoteData = deleteRemoteData,
        super(_initializeState(auth)) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        state = AppAuthAuthenticated(user.uid);
      } else {
        state = const AppAuthUnauthenticated();
      }
    });
  }

  static AppAuthState _initializeState(FirebaseAuth auth) {
    final user = auth.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      return AppAuthAuthenticated(user.uid);
    }
    return const AppAuthUnauthenticated();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AppAuthLoading();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user?.uid;
      if (userId == null) {
        state = const AppAuthError('로그인을 완료할 수 없습니다. 잠시 후 다시 시도해주세요.');
        return;
      }

      try {
        // 로그인 직후 로컬에서 누적된 계산 이력을 서버와 맞춘다.
        // 실패해도 로그인 자체는 유지되어야 하므로 에러를 삼킨다.
        await _repo.syncWithRemote();
      } catch (_) {
        // 동기화 실패가 로그인을 막지 않도록 로컬 데이터는 유지합니다.
      }

      state = AppAuthAuthenticated(userId);
    } on FirebaseAuthException catch (e) {
      state = AppAuthError(_messageForSignInError(e));
    } catch (e) {
      state = const AppAuthError('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AppAuthLoading();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        state = const AppAuthError('회원가입을 완료할 수 없습니다. 잠시 후 다시 시도해주세요.');
        return;
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        state = AppAuthPendingVerification(email);
        return;
      }

      try {
        await _repo.syncWithRemote();
      } catch (_) {}

      state = AppAuthAuthenticated(user.uid);
    } on FirebaseAuthException catch (e) {
      state = AppAuthError(_messageForSignUpError(e));
    } catch (e) {
      state = const AppAuthError('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageForResetPasswordError(e);
    } catch (e) {
      return '네트워크 연결을 확인한 뒤 다시 시도해주세요.';
    }
  }

  Future<void> signOut() async {
    try {
      // 로그아웃 전에 FCM 토큰을 제거해서 다른 계정으로 공지가 섞이지 않게 한다.
      await _beforeSignOut?.call();
      await _auth.signOut();
      state = const AppAuthUnauthenticated();
    } catch (e) {
      state = const AppAuthError('로그아웃을 완료할 수 없습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  Future<String?> deleteAccount() async {
    final previous = state;
    state = const AppAuthLoading();
    try {
      await _beforeSignOut?.call();
      final user = _auth.currentUser;
      if (user != null) {
        final deleteRemoteData = _deleteRemoteData ?? _deleteUserRemoteData;
        await deleteRemoteData(user.uid);
        await user.delete();
      }
      await _repo.clearLocal();
      state = const AppAuthUnauthenticated();
      return null;
    } catch (e) {
      state = previous;
      return '회원탈퇴를 완료할 수 없습니다. 다시 로그인한 뒤 시도해주세요.';
    }
  }

  bool get isAuthenticated => state is AppAuthAuthenticated;

  String? get currentUserId => state is AppAuthAuthenticated
      ? (state as AppAuthAuthenticated).userId
      : null;

  String _messageForSignInError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
      case 'user-disabled':
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호를 확인해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인한 뒤 다시 시도해주세요.';
      default:
        return '로그인을 완료할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  String _messageForSignUpError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return '이미 가입된 이메일입니다. 로그인하거나 비밀번호 찾기를 이용해주세요.';
      case 'invalid-email':
        return '올바른 이메일 형식이 아닙니다.';
      case 'weak-password':
        return '비밀번호는 6자 이상으로 입력해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인한 뒤 다시 시도해주세요.';
      default:
        return '회원가입을 완료할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  String _messageForResetPasswordError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
      case 'user-not-found':
        return '이메일 또는 비밀번호를 확인해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인한 뒤 다시 시도해주세요.';
      default:
        return '비밀번호 재설정 메일을 보낼 수 없습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  Future<void> _deleteUserRemoteData(String userId) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(userId);
    await _deleteCollection(userDoc.collection('calculation_history'));
    await _deleteCollection(userDoc.collection('notice_reads'));
    await userDoc.delete();

    final tokenSnapshot = await firestore
        .collection('push_tokens')
        .where('user_id', isEqualTo: userId)
        .get();
    final batch = firestore.batch();
    for (final doc in tokenSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    while (true) {
      final snapshot = await collection.limit(100).get();
      if (snapshot.docs.isEmpty) return;
      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final repo = ref.read(calculationHistoryRepositoryProvider);
  return AuthNotifier(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    repo: repo,
    beforeSignOut: () => ref.read(firebasePushServiceProvider).stop(),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/calculation_history_repository.dart';
import '../../providers/calculation_history_provider.dart';
import '../../core/notifications/firebase_push_service.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AppAuthState> {
  final SupabaseClient _client;
  final CalculationHistoryRepository _repo;
  final Future<void> Function()? _beforeSignOut;

  AuthNotifier({
    required SupabaseClient client,
    required CalculationHistoryRepository repo,
    Future<void> Function()? beforeSignOut,
  })  : _client = client,
        _repo = repo,
        _beforeSignOut = beforeSignOut,
        super(_initializeState(client)) {
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        state = AppAuthAuthenticated(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AppAuthUnauthenticated();
      }
    });
  }

  static AppAuthState _initializeState(SupabaseClient client) {
    final session = client.auth.currentSession;
    if (session != null && session.user.id.isNotEmpty) {
      return AppAuthAuthenticated(session.user.id);
    }
    return const AppAuthUnauthenticated();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AppAuthLoading();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        state = const AppAuthError('Sign in failed: No user ID returned');
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
    } on AuthException catch (e) {
      state = AppAuthError(e.message);
    } catch (e) {
      state = AppAuthError(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AppAuthLoading();

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'com.sungals.housemoneycalculator://login-callback/',
      );

      final user = response.user;
      if (user == null) {
        state = const AppAuthError('Sign up failed: No user returned');
        return;
      }

      // session이 null이면 이메일 인증 대기 중
      if (response.session == null) {
        state = AppAuthPendingVerification(email);
        return;
      }

      try {
        await _repo.syncWithRemote();
      } catch (_) {}

      state = AppAuthAuthenticated(user.id);
    } on AuthException catch (e) {
      state = AppAuthError(e.message);
    } catch (e) {
      state = AppAuthError(e.toString());
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      // 로그아웃 전에 FCM 토큰을 제거해서 다른 계정으로 공지가 섞이지 않게 한다.
      await _beforeSignOut?.call();
      await _client.auth.signOut();
      state = const AppAuthUnauthenticated();
    } catch (e) {
      state = AppAuthError('Sign out failed: ${e.toString()}');
    }
  }

  Future<String?> deleteAccount() async {
    final previous = state;
    state = const AppAuthLoading();
    try {
      // 계정 삭제는 Supabase RPC에서 auth 사용자와 관련 서버 데이터를 정리한다.
      await _beforeSignOut?.call();
      await _client.rpc('delete_account');
      await _repo.clearLocal();
      state = const AppAuthUnauthenticated();
      return null;
    } catch (e) {
      state = previous;
      return e.toString();
    }
  }

  bool get isAuthenticated => state is AppAuthAuthenticated;

  String? get currentUserId => state is AppAuthAuthenticated
      ? (state as AppAuthAuthenticated).userId
      : null;
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final client = Supabase.instance.client;
  final repo = ref.read(calculationHistoryRepositoryProvider);
  return AuthNotifier(
    client: client,
    repo: repo,
    beforeSignOut: () => ref.read(firebasePushServiceProvider).stop(),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/calculation_history_repository.dart';
import '../../providers/calculation_history_provider.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AppAuthState> {
  final SupabaseClient _client;
  final CalculationHistoryRepository _repo;

  AuthNotifier({
    required SupabaseClient client,
    required CalculationHistoryRepository repo,
  })  : _client = client,
        _repo = repo,
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

      // Migrate local records to remote on first login
      try {
        await _repo.migrateLocalToRemote();
      } catch (_) {
        // Log or handle migration error silently to not block login
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
        await _repo.migrateLocalToRemote();
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
      await _client.auth.signOut();
      state = const AppAuthUnauthenticated();
    } catch (e) {
      state = AppAuthError('Sign out failed: ${e.toString()}');
    }
  }

  bool get isAuthenticated => state is AppAuthAuthenticated;

  String? get currentUserId =>
      state is AppAuthAuthenticated ? (state as AppAuthAuthenticated).userId : null;
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final client = Supabase.instance.client;
  final repo = ref.read(calculationHistoryRepositoryProvider);
  return AuthNotifier(client: client, repo: repo);
});

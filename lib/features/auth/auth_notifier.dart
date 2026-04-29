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
        super(_initializeState(client));

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

      final userId = response.user?.id;
      if (userId == null) {
        state = const AppAuthError('Sign up failed: No user ID returned');
        return;
      }

      // Migrate local records to remote on first sign up
      try {
        await _repo.migrateLocalToRemote();
      } catch (_) {
        // Log or handle migration error silently to not block signup
      }

      state = AppAuthAuthenticated(userId);
    } on AuthException catch (e) {
      state = AppAuthError(e.message);
    } catch (e) {
      state = AppAuthError(e.toString());
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

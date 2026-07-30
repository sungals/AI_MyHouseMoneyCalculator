import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/features/auth/auth_notifier.dart';
import 'package:house_money_calculator/features/auth/auth_state.dart';
import 'package:house_money_calculator/data/repositories/calculation_history_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockCalculationHistoryRepository extends Mock
    implements CalculationHistoryRepository {}

void main() {
  group('AuthNotifier', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late MockCalculationHistoryRepository mockRepository;
    late AuthNotifier authNotifier;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      mockRepository = MockCalculationHistoryRepository();

      // Default mock behavior
      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
      when(() => mockGoTrueClient.currentSession).thenReturn(null);
      when(() => mockGoTrueClient.onAuthStateChange)
          .thenAnswer((_) => const Stream<AuthState>.empty());
      when(() => mockRepository.syncWithRemote()).thenAnswer((_) async => {});
    });

    group('initialization', () {
      test('initial state is AuthUnauthenticated when no session exists', () {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);

        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );

        expect(authNotifier.state, isA<AppAuthUnauthenticated>());
      });

      test('initial state is AuthAuthenticated when session exists', () {
        final mockUser = MockUser();
        final mockSession = MockSession();

        when(() => mockUser.id).thenReturn('user_123');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);

        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );

        expect(authNotifier.state, isA<AppAuthAuthenticated>());
        expect(
          (authNotifier.state as AppAuthAuthenticated).userId,
          equals('user_123'),
        );
      });

      test('currentUserId returns null when not authenticated', () {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);

        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );

        expect(authNotifier.currentUserId, isNull);
      });

      test('currentUserId returns userId when authenticated', () {
        final mockUser = MockUser();
        final mockSession = MockSession();

        when(() => mockUser.id).thenReturn('user_456');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);

        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );

        expect(authNotifier.currentUserId, equals('user_456'));
      });

      test('isAuthenticated returns false when not authenticated', () {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);

        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );

        expect(authNotifier.isAuthenticated, isFalse);
      });

      test('isAuthenticated returns true when authenticated', () {
        final mockUser = MockUser();
        final mockSession = MockSession();

        when(() => mockUser.id).thenReturn('user_789');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);

        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );

        expect(authNotifier.isAuthenticated, isTrue);
      });
    });

    group('signInWithEmail', () {
      setUp(() {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);
        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );
      });

      test('emits [AuthLoading, AuthAuthenticated] on successful sign in',
          () async {
        final mockUser = MockUser();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('signed_in_user_123');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        await authNotifier.signInWithEmail('test@example.com', 'password123');

        expect(authNotifier.state, isA<AppAuthAuthenticated>());
        expect(
          (authNotifier.state as AppAuthAuthenticated).userId,
          'signed_in_user_123',
        );
      });

      test('calls syncWithRemote on successful sign in', () async {
        final mockUser = MockUser();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('signed_in_user_456');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        await authNotifier.signInWithEmail('test@example.com', 'password123');

        verify(() => mockRepository.syncWithRemote()).called(1);
      });

      test('emits [AuthLoading, AuthError] on AuthException', () async {
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'test@example.com',
            password: 'wrong_password',
          ),
        ).thenThrow(
          const AuthException('Invalid login credentials'),
        );

        await authNotifier.signInWithEmail(
            'test@example.com', 'wrong_password');

        expect(authNotifier.state, isA<AppAuthError>());
        expect(
          (authNotifier.state as AppAuthError).message,
          '이메일 또는 비밀번호를 확인해주세요.',
        );
      });

      test('emits [AuthLoading, AuthError] on generic Exception', () async {
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenThrow(Exception('Network error'));

        await authNotifier.signInWithEmail('test@example.com', 'password123');

        expect(authNotifier.state, isA<AppAuthError>());
        expect(
          (authNotifier.state as AppAuthError).message,
          '네트워크 연결을 확인한 뒤 다시 시도해주세요.',
        );
      });

      test('emits AuthError when user ID is null', () async {
        final mockAuthResponse = MockAuthResponse();

        when(() => mockAuthResponse.user).thenReturn(null);
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        await authNotifier.signInWithEmail('test@example.com', 'password123');

        expect(authNotifier.state, isA<AppAuthError>());
        expect(
          (authNotifier.state as AppAuthError).message,
          '로그인을 완료할 수 없습니다. 잠시 후 다시 시도해주세요.',
        );
      });

      test('continues to AuthAuthenticated even if sync fails', () async {
        final mockUser = MockUser();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('signed_in_user_789');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);
        when(() => mockRepository.syncWithRemote())
            .thenThrow(Exception('Sync failed'));

        await authNotifier.signInWithEmail('test@example.com', 'password123');

        expect(authNotifier.state, isA<AppAuthAuthenticated>());
        expect(
          (authNotifier.state as AppAuthAuthenticated).userId,
          'signed_in_user_789',
        );
      });
    });

    group('signUpWithEmail', () {
      setUp(() {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);
        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );
      });

      test('emits [AuthLoading, AuthAuthenticated] on successful sign up',
          () async {
        final mockUser = MockUser();
        final mockSession = MockSession();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('new_user_123');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(() => mockAuthResponse.session).thenReturn(mockSession);
        when(
          () => mockGoTrueClient.signUp(
            email: 'newuser@example.com',
            password: 'newpassword123',
            emailRedirectTo: any(named: 'emailRedirectTo'),
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        await authNotifier.signUpWithEmail(
          'newuser@example.com',
          'newpassword123',
        );

        expect(authNotifier.state, isA<AppAuthAuthenticated>());
        expect(
          (authNotifier.state as AppAuthAuthenticated).userId,
          'new_user_123',
        );
      });

      test('calls syncWithRemote on successful sign up', () async {
        final mockUser = MockUser();
        final mockSession = MockSession();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('new_user_456');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(() => mockAuthResponse.session).thenReturn(mockSession);
        when(
          () => mockGoTrueClient.signUp(
            email: 'newuser@example.com',
            password: 'newpassword123',
            emailRedirectTo: any(named: 'emailRedirectTo'),
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        await authNotifier.signUpWithEmail(
          'newuser@example.com',
          'newpassword123',
        );

        verify(() => mockRepository.syncWithRemote()).called(1);
      });

      test('emits [AuthLoading, AuthError] on AuthException', () async {
        when(
          () => mockGoTrueClient.signUp(
            email: 'existing@example.com',
            password: 'password123',
            emailRedirectTo: any(named: 'emailRedirectTo'),
          ),
        ).thenThrow(
          const AuthException('User already registered'),
        );

        await authNotifier.signUpWithEmail(
          'existing@example.com',
          'password123',
        );

        expect(authNotifier.state, isA<AppAuthError>());
        expect(
          (authNotifier.state as AppAuthError).message,
          '이미 가입된 이메일입니다. 로그인하거나 비밀번호 찾기를 이용해주세요.',
        );
      });

      test('emits AuthError when user ID is null', () async {
        final mockAuthResponse = MockAuthResponse();

        when(() => mockAuthResponse.user).thenReturn(null);
        when(
          () => mockGoTrueClient.signUp(
            email: 'newuser@example.com',
            password: 'password123',
            emailRedirectTo: any(named: 'emailRedirectTo'),
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        await authNotifier.signUpWithEmail(
          'newuser@example.com',
          'password123',
        );

        expect(authNotifier.state, isA<AppAuthError>());
        expect(
          (authNotifier.state as AppAuthError).message,
          '회원가입을 완료할 수 없습니다. 잠시 후 다시 시도해주세요.',
        );
      });

      test('continues to AuthAuthenticated even if sync fails', () async {
        final mockUser = MockUser();
        final mockSession = MockSession();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('new_user_789');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(() => mockAuthResponse.session).thenReturn(mockSession);
        when(
          () => mockGoTrueClient.signUp(
            email: 'newuser@example.com',
            password: 'password123',
            emailRedirectTo: any(named: 'emailRedirectTo'),
          ),
        ).thenAnswer((_) async => mockAuthResponse);
        when(() => mockRepository.syncWithRemote())
            .thenThrow(Exception('Sync failed'));

        await authNotifier.signUpWithEmail(
          'newuser@example.com',
          'password123',
        );

        expect(authNotifier.state, isA<AppAuthAuthenticated>());
        expect(
          (authNotifier.state as AppAuthAuthenticated).userId,
          'new_user_789',
        );
      });
    });

    group('signOut', () {
      setUp(() {
        final mockUser = MockUser();
        final mockSession = MockSession();

        when(() => mockUser.id).thenReturn('current_user');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);

        authNotifier = AuthNotifier(
          client: mockSupabaseClient,
          repo: mockRepository,
        );
      });

      test('emits AuthUnauthenticated on successful sign out', () async {
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});

        await authNotifier.signOut();

        expect(authNotifier.state, isA<AppAuthUnauthenticated>());
      });

      test('calls auth.signOut', () async {
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});

        await authNotifier.signOut();

        verify(() => mockGoTrueClient.signOut()).called(1);
      });

      test('emits AuthError on signOut exception', () async {
        when(() => mockGoTrueClient.signOut())
            .thenThrow(Exception('Sign out failed'));

        await authNotifier.signOut();

        expect(authNotifier.state, isA<AppAuthError>());
        expect(
          (authNotifier.state as AppAuthError).message,
          contains('Sign out failed'),
        );
      });
    });
  });
}

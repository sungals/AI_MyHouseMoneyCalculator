import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/data/repositories/calculation_history_repository.dart';
import 'package:house_money_calculator/features/auth/auth_notifier.dart';
import 'package:house_money_calculator/features/auth/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockCalculationHistoryRepository extends Mock
    implements CalculationHistoryRepository {}

void main() {
  group('AuthNotifier', () {
    late MockFirebaseAuth auth;
    late MockCalculationHistoryRepository repository;
    late AuthNotifier notifier;

    setUp(() {
      auth = MockFirebaseAuth();
      repository = MockCalculationHistoryRepository();
      when(() => auth.currentUser).thenReturn(null);
      when(() => auth.authStateChanges())
          .thenAnswer((_) => const Stream<User?>.empty());
      when(() => repository.syncWithRemote()).thenAnswer((_) async {});
      when(() => repository.clearLocal()).thenAnswer((_) async {});
    });

    AuthNotifier createNotifier() {
      return AuthNotifier(
        auth: auth,
        repo: repository,
        deleteRemoteData: (_) async {},
      );
    }

    test('initial state is unauthenticated when no user exists', () {
      notifier = createNotifier();

      expect(notifier.state, isA<AppAuthUnauthenticated>());
    });

    test('initial state is authenticated when Firebase user exists', () {
      final user = MockUser();
      when(() => user.uid).thenReturn('user_123');
      when(() => auth.currentUser).thenReturn(user);

      notifier = createNotifier();

      expect(notifier.state, isA<AppAuthAuthenticated>());
      expect((notifier.state as AppAuthAuthenticated).userId, 'user_123');
    });

    group('signInWithEmail', () {
      setUp(() {
        notifier = createNotifier();
      });

      test('authenticates and syncs history on success', () async {
        final user = MockUser();
        final credential = MockUserCredential();
        when(() => user.uid).thenReturn('signed_in_user');
        when(() => credential.user).thenReturn(user);
        when(
          () => auth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => credential);

        await notifier.signInWithEmail('test@example.com', 'password123');

        expect(notifier.state, isA<AppAuthAuthenticated>());
        expect(
          (notifier.state as AppAuthAuthenticated).userId,
          'signed_in_user',
        );
        verify(() => repository.syncWithRemote()).called(1);
      });

      test('shows friendly message on invalid credentials', () async {
        when(
          () => auth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'wrong_password',
          ),
        ).thenThrow(
          FirebaseAuthException(code: 'invalid-credential'),
        );

        await notifier.signInWithEmail('test@example.com', 'wrong_password');

        expect(notifier.state, isA<AppAuthError>());
        expect(
          (notifier.state as AppAuthError).message,
          '이메일 또는 비밀번호를 확인해주세요.',
        );
      });

      test('continues authenticated even if history sync fails', () async {
        final user = MockUser();
        final credential = MockUserCredential();
        when(() => user.uid).thenReturn('signed_in_user');
        when(() => credential.user).thenReturn(user);
        when(
          () => auth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => credential);
        when(() => repository.syncWithRemote()).thenThrow(Exception('sync'));

        await notifier.signInWithEmail('test@example.com', 'password123');

        expect(notifier.state, isA<AppAuthAuthenticated>());
      });
    });

    group('signUpWithEmail', () {
      setUp(() {
        notifier = createNotifier();
      });

      test('sends verification email when newly created user is unverified',
          () async {
        final user = MockUser();
        final credential = MockUserCredential();
        when(() => user.emailVerified).thenReturn(false);
        when(() => user.sendEmailVerification()).thenAnswer((_) async {});
        when(() => credential.user).thenReturn(user);
        when(
          () => auth.createUserWithEmailAndPassword(
            email: 'new@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => credential);

        await notifier.signUpWithEmail('new@example.com', 'password123');

        expect(notifier.state, isA<AppAuthPendingVerification>());
        expect(
          (notifier.state as AppAuthPendingVerification).email,
          'new@example.com',
        );
        verify(() => user.sendEmailVerification()).called(1);
      });

      test('shows friendly message when email is already registered', () async {
        when(
          () => auth.createUserWithEmailAndPassword(
            email: 'existing@example.com',
            password: 'password123',
          ),
        ).thenThrow(
          FirebaseAuthException(code: 'email-already-in-use'),
        );

        await notifier.signUpWithEmail('existing@example.com', 'password123');

        expect(notifier.state, isA<AppAuthError>());
        expect(
          (notifier.state as AppAuthError).message,
          '이미 가입된 이메일입니다. 로그인하거나 비밀번호 찾기를 이용해주세요.',
        );
      });
    });

    group('signOut', () {
      test('signs out from Firebase', () async {
        notifier = createNotifier();
        when(() => auth.signOut()).thenAnswer((_) async {});

        await notifier.signOut();

        expect(notifier.state, isA<AppAuthUnauthenticated>());
        verify(() => auth.signOut()).called(1);
      });
    });

    group('deleteAccount', () {
      test('deletes Firebase user and clears local history', () async {
        final user = MockUser();
        when(() => auth.currentUser).thenReturn(user);
        when(() => user.uid).thenReturn('user_123');
        when(() => user.delete()).thenAnswer((_) async {});

        notifier = createNotifier();

        final error = await notifier.deleteAccount();

        expect(error, isNull);
        expect(notifier.state, isA<AppAuthUnauthenticated>());
        verify(() => user.delete()).called(1);
        verify(() => repository.clearLocal()).called(1);
      });
    });
  });
}

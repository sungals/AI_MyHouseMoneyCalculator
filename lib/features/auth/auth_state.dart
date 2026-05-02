sealed class AppAuthState {
  const AppAuthState();
}

class AppAuthUnauthenticated extends AppAuthState {
  const AppAuthUnauthenticated();
}

class AppAuthLoading extends AppAuthState {
  const AppAuthLoading();
}

class AppAuthAuthenticated extends AppAuthState {
  final String userId;

  const AppAuthAuthenticated(this.userId);
}

class AppAuthError extends AppAuthState {
  final String message;

  const AppAuthError(this.message);
}

class AppAuthPendingVerification extends AppAuthState {
  final String email;

  const AppAuthPendingVerification(this.email);
}

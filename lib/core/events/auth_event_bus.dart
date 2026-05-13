import 'dart:async';

/// Auth lifecycle events emitted by `AuthInterceptor` (on session expiry) and
/// `AuthViewModel` (on explicit logout).
///
/// Sealed so subscribers can switch exhaustively.
sealed class AuthEvent {
  const AuthEvent();
}

/// The backend returned 401 on an authenticated request — token is gone.
/// Subscribers typically navigate to the sign-in screen and clear caches.
class SessionExpired extends AuthEvent {
  const SessionExpired();
}

/// The user explicitly logged out. Distinct from `SessionExpired` so caches
/// that should survive a session refresh (but not a user switch) can react
/// differently.
class LoggedOut extends AuthEvent {
  const LoggedOut();
}

/// App-wide broadcast bus for auth events.
///
/// Static, single instance — auth is global state. The broadcast controller
/// allows multiple listeners (router, in-memory caches, FCM token cache)
/// without coupling them to each other.
class AuthEventBus {
  AuthEventBus._();

  static final StreamController<AuthEvent> _controller =
      StreamController<AuthEvent>.broadcast();

  static Stream<AuthEvent> get stream => _controller.stream;

  static void emit(AuthEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }
}

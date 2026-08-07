import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_education/core/config/route/app_navigator.dart';
import 'package:project_education/core/config/route/app_routes.dart';

/// Listens for `learnshelf://auth-callback` links (signup confirmation and
/// password recovery) on both cold start and while the app is running.
///
/// Supabase's default auth flow for deep links is PKCE: the incoming link
/// carries a `code` param, not a `type` param. We exchange that code for a
/// session ourselves, then rely on the SDK's own `onAuthStateChange` event
/// (`passwordRecovery` vs `signedIn`) to tell which flow the link belonged
/// to — that's the only reliable signal under PKCE.
///
/// For the signup case, we deliberately sign the resulting session back out
/// immediately — verifying an email should never auto-log a user in; they
/// must sign in explicitly afterwards.
class DeepLinkHandler {
  DeepLinkHandler._();
  static final DeepLinkHandler instance = DeepLinkHandler._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    // Cold start: app was launched by tapping the link.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } catch (_) {
      // No initial link — normal cold start, nothing to do.
    }

    // Warm start: app already running when the link is tapped.
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (_) {},
    );
  }

  Future<void> _handleUri(Uri uri) async {
    final code = uri.queryParameters['code'];
    if (code == null) {
      // Not an auth callback we recognize — ignore safely.
      return;
    }

    StreamSubscription<AuthState>? authListener;
    final completer = Completer<AuthChangeEvent>();

    // Listen right before exchanging so we capture the very next auth
    // event as the one caused by this exchange, not an unrelated one.
    authListener = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!completer.isCompleted) {
        completer.complete(data.event);
      }
    });

    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(code);
      final event = await completer.future.timeout(const Duration(seconds: 5));

      if (event == AuthChangeEvent.passwordRecovery) {
        AppNavigator.pushReplacementNamed(AppRoutes.resetPassword);
      } else {
        // signedIn — this was a signup confirmation link. Sign back out
        // so verifying an email never silently logs the user in.
        await Supabase.instance.client.auth.signOut();
        AppNavigator.pushReplacementNamed(AppRoutes.emailVerifiedSuccess);
      }
    } catch (_) {
      // Code expired, already used, or a network error mid-exchange.
      // Send them to Sign In rather than stranding them on a dead link.
      AppNavigator.pushReplacementNamed(AppRoutes.signInScreen);
    } finally {
      await authListener.cancel();
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
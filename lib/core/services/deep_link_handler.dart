import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_education/core/config/route/app_navigator.dart';
import 'package:project_education/core/config/route/app_routes.dart';

/// Listens for `learnshelf://auth-callback` links (signup confirmation and
/// password recovery) on both cold start and while the app is running, and
/// routes to the correct screen based on the `type` query parameter.
///
/// Note: Supabase's own SDK also listens for these links internally and
/// will establish a session in the background regardless of what we do
/// here. For the signup case, we deliberately sign that session back out
/// immediately — the product decision is that verifying an email should
/// never auto-log a user in; they must sign in explicitly afterwards.
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
    final type = uri.queryParameters['type'];

    switch (type) {
      case 'signup':
        // Supabase may have auto-established a session for this
        // confirmation. Force sign-out so the user must sign in explicitly.
        await Supabase.instance.client.auth.signOut();
        AppNavigator.pushReplacementNamed(AppRoutes.emailVerifiedSuccess);
        break;

      case 'recovery':
        // A recovery session IS needed here for updatePassword() to work,
        // so we deliberately do NOT sign out on this branch.
        AppNavigator.pushReplacementNamed(AppRoutes.resetPassword);
        break;

      default:
        // magiclink or unrecognized type — no feature built for these,
        // safely ignored.
        break;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
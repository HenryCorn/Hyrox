import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/api_client.dart';
import '../services/token_storage.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(tokenStorageProvider));
});

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ── State ─────────────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String displayName;
  final String accessToken;
  const AuthAuthenticated({
    required this.userId,
    required this.displayName,
    required this.accessToken,
  });
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthState> {
  static final _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Future<AuthState> build() async {
    // Restore persisted session on app start
    final storage = ref.read(tokenStorageProvider);
    final session = await storage.loadSession();
    if (session == null) return const AuthUnauthenticated();
    return AuthAuthenticated(
      userId: session.userId,
      displayName: session.displayName,
      accessToken: session.accessToken,
    );
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final displayName = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().join(' ').trim();

      await _exchangeToken(
        provider: 'apple',
        identityToken: credential.identityToken!,
        displayName: displayName.isNotEmpty ? displayName : null,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = const AsyncData(AuthUnauthenticated());
        return;
      }
      final auth = await account.authentication;
      await _exchangeToken(
        provider: 'google',
        identityToken: auth.idToken!,
        displayName: account.displayName,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    final storage = ref.read(tokenStorageProvider);
    await storage.clearSession();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    state = const AsyncData(AuthUnauthenticated());
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  Future<void> _exchangeToken({
    required String provider,
    required String identityToken,
    String? displayName,
  }) async {
    final api = ref.read(apiClientProvider);
    final response = await api.post<Map<String, dynamic>>(
      '/api/auth/signin',
      data: {
        'provider': provider,
        'identityToken': identityToken,
        if (displayName != null) 'displayName': displayName,
      },
    );

    final body = response.data!;
    final accessToken = body['accessToken'] as String;
    final user = body['user'] as Map<String, dynamic>;
    final userId = user['id'] as String;
    final name = user['displayName'] as String;

    final storage = ref.read(tokenStorageProvider);
    await storage.saveSession(
      accessToken: accessToken,
      userId: userId,
      displayName: name,
    );

    state = AsyncData(AuthAuthenticated(
      userId: userId,
      displayName: name,
      accessToken: accessToken,
    ));
  }
}

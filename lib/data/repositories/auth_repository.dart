import 'package:kasway/app/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  bool get isSignedIn => _client.auth.currentUser != null;

  /// Returns true if the current user has a Google identity linked.
  bool get hasGoogleLinked {
    final identities = _client.auth.currentUser?.identities ?? [];
    return identities.any((id) => id.provider == 'google');
  }

  /// Primary login method — Google OAuth.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Env.authRedirectUrl,
    );
  }

  /// Links a Google identity to the current account (first-time setup after invitation).
  Future<void> linkGoogle() async {
    await _client.auth.linkIdentity(
      OAuthProvider.google,
      redirectTo: Env.authRedirectUrl,
    );
  }

  /// Marks the current branch member's status as 'active'.
  /// Pass [name] to set the member's display name during first-time setup.
  Future<void> activateBranchMember({String? name}) async {
    await _client.rpc(
      'activate_branch_member',
      params: name != null ? {'member_name': name} : {},
    );
  }

  /// Sends a one-time password to [email] for passwordless sign-in.
  Future<void> sendOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  /// Verifies the OTP [token] for [email].
  Future<void> verifyOtp(String email, String token) async {
    await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

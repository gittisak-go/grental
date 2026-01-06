// Web stub for Google Sign In
// This file is used when compiling for web platform

class GoogleSignIn {
  GoogleSignIn({String? serverClientId});

  Future<GoogleSignInAccount?> signInSilently() async => null;
  Future<GoogleSignInAccount?> signIn() async => null;
  Future<bool> isSignedIn() async => false;
  Future<GoogleSignInAccount?> signOut() async => null;
}

class GoogleSignInAccount {
  Future<GoogleSignInAuthentication> get authentication async =>
      GoogleSignInAuthentication();
}

class GoogleSignInAuthentication {
  String? get idToken => null;
  String? get accessToken => null;
}

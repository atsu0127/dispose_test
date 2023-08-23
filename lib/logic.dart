import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 認証関係
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  ref.onDispose(() {
    debugPrint("firebaseAuthProvider disposed");
  });
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>(
  (ref) => AuthRepositoryImpl(ref.watch(firebaseAuthProvider)),
);

class AuthRepositoryImpl {
  AuthRepositoryImpl(this._auth);

  final FirebaseAuth _auth;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

/// ログイン検知
final firebaseUserProvider = StreamProvider<User?>(
  (ref) {
    ref.onDispose(() {
      debugPrint("firebaseUserProvider disposed");
    });
    return ref.watch(firebaseAuthProvider).authStateChanges();
  },
);

final appUserProvider = StreamProvider<String?>((ref) async* {
  ref.onDispose(() {
    debugPrint("appUserProvider disposed");
  });

  final firebaseUserAsync = ref.watch(firebaseUserProvider);
  final user = firebaseUserAsync.asData?.value;
  debugPrint("State Changed: $user");
  if (user == null) {
    yield null;
  }

  yield user?.email;
});

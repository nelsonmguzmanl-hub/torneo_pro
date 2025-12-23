import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../constants/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<AppUser?> get currentUserStream {
    return authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _firestoreService.getUser(firebaseUser.uid);
    });
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.user,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user!;
    final providerId = firebaseUser.providerData.isNotEmpty
        ? firebaseUser.providerData.first.providerId
        : 'password';

    final user = AppUser(
      uid: userCredential.user!.uid,
      name: name,
      email: email,
      role: role,
      status: UserStatus.active,
      createdAt: Timestamp.now(),
      photo: firebaseUser.photoURL ?? '',
      provider: providerId,

    );

    await _firestoreService.createUser(user);
    return user;
  }

  Future<AppUser?> login({required String email, required String password}) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );


    final uid = userCredential.user!.uid;
    final appUser = await _firestoreService.getUser(uid);
    return appUser;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

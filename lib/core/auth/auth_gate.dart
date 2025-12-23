import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/login_page.dart';
import '../../features/home/admin_home_page.dart';
import '../../features/home/user_home_page.dart';
import '../../features/auth/suspended_page.dart';
import '../../features/auth/unauthorized_page.dart';
import '../../core/constants/enums.dart';
import '../../models/user_model.dart';
import '../../core/services/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Firebase aún validando sesión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Sin sesión
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final firebaseUser = snapshot.data!;

        // ✅ Sesión activa → cargar usuario de Firestore
        return FutureBuilder<AppUser?>(
          future: UserService.getUser(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = userSnapshot.data;

            if (user == null) {
              return const UnauthorizedPage();
            }

            if (user.status != UserStatus.active) {
              return const SuspendedPage();
            }

            if (user.role == UserRole.admin) {
              return const AdminHomePage();
            }

            if (user.role == UserRole.user) {
              return const UserHomePage();
            }

            return const UnauthorizedPage();
          },
        );
      },
    );
  }
}
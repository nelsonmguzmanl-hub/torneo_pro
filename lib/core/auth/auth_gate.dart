import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/providers/user_provider.dart';
import '../../core/constants/enums.dart';
import '../../models/user_model.dart';
import '../../features/auth/login_page.dart';
import '../../features/home/admin_home_page.dart';
import '../../features/home/user_home_page.dart';
import '../../features/auth/suspended_page.dart';
import '../../features/auth/unauthorized_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Cargando sesión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ No hay sesión
        if (!snapshot.hasData) {
          userProvider.clearUser();
          return const LoginPage();
        }

        final firebaseUser = snapshot.data!;
        final appUser = userProvider.user;

        // Si no tenemos AppUser en Provider, cargarlo desde Firestore
        if (appUser == null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                userProvider.clearUser();
                return const LoginPage();
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>;
              final loadedUser = AppUser.fromMap(firebaseUser.uid, data);
              userProvider.setUser(loadedUser);

              return _redirectBasedOnStatusAndRole(loadedUser);
            },
          );
        }

        return _redirectBasedOnStatusAndRole(appUser);
      },
    );
  }

  Widget _redirectBasedOnStatusAndRole(AppUser user) {
    if (user.status != UserStatus.active) {
      return const SuspendedPage();
    }

    if (user.role == UserRole.admin) {
      return const AdminHomePage();
    } else if (user.role == UserRole.user) {
      return const UserHomePage();
    } else {
      return const UnauthorizedPage();
    }
  }
}

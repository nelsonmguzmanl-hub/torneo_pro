import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/auth/auth_service.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/enums.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AppUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // 🔒 No hay sesión → Login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final appUser = await _firestoreService.getUser(firebaseUser.uid);

    if (appUser == null) {
      // Usuario inválido
      await _authService.logout();
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (appUser.role != UserRole.admin) {
      // 🚫 No es admin → Home de usuario
      Navigator.pushReplacementNamed(context, '/user_home');
      return;
    }

    setState(() {
      _user = appUser;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${_user!.name}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _user!.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 🔧 Opciones del panel
            _AdminOption(
              icon: Icons.emoji_events,
              title: 'Torneos',
              onTap: () {
                // Navigator.pushNamed(context, '/admin_torneos');
              },
            ),
            _AdminOption(
              icon: Icons.people,
              title: 'Usuarios',
              onTap: () {
                // Navigator.pushNamed(context, '/admin_usuarios');
              },
            ),
            _AdminOption(
              icon: Icons.settings,
              title: 'Configuración',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

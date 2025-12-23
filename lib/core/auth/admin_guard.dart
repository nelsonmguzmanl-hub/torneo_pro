import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../constants/enums.dart';

class AdminGuard extends StatelessWidget {
  final AppUser user;
  final Widget child;

  const AdminGuard({
    super.key,
    required this.user,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (user.role != UserRole.admin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Acceso denegado',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    return child;
  }
}

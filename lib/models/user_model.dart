import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final UserStatus status;
  final Timestamp createdAt;
  final String photo;
  final String provider;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.photo,
    required this.provider,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'],
      email: data['email'],
      role: _parseRole(data['role']),
      status: _parseStatus(data['status']),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      photo: data['photo'] ?? '',
      provider: data['provider'] ?? 'app',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'status': status.name,
      'createdAt': createdAt,
      'photo': photo,
      'provider': provider,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.unauthorized;
    }
  }

  static UserStatus _parseStatus(String? status) {
    switch (status) {
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.active;
    }
  }
}
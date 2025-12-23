import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/auth/auth_providers.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;

  static const Color primaryGreen = Color(0xFF13EC37);
  static const Color bgLight = Color(0xFFF8FCF9);
  static const Color bgDark = Color(0xFF102213);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1C3020);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  Future<void> registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError(l10n.fillAllFields);
      return;
    }

    if (!isValidEmail(email)) {
      _showError(l10n.invalidEmail);
      return;
    }

    if (password.length < 6) {
      _showError(l10n.passwordTooShort);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'role': 'user',
        'status': 'active',
        'photo': '',
        'provider': 'app',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/user_home');

    } on FirebaseAuthException catch (e) {
      final l10n = AppLocalizations.of(context)!;

      String msg = l10n.registerError;
      if (e.code == 'email-already-in-use') {
        msg = l10n.emailAlreadyInUse;
      }
      if (e.code == 'weak-password') {
        msg = l10n.weakPassword;
      }
      _showError(msg);

    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> registerWithProvider(
  Future<User?> Function() signInMethod) async {

    setState(() => _isLoading = true);

    try {
      final user = await signInMethod();
      if (user == null) return;

      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        await docRef.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'user',
          'status': 'active',
          'photo': user.photoURL ?? '',
          'provider': user.providerData.first.providerId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/user_home');

    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.registerError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // ---------------- TOP BAR ----------------
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white : const Color(0xFF0D1B10),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          l10n.registerTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // ---------------- CONTENT ----------------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // Logo
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              size: 36,
                              color: primaryGreen,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          l10n.registerHeadline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          l10n.registerSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // -------- NAME --------
                        _InputField(
                          label: l10n.fullNameLabel,
                          hint: l10n.fullNameHint,
                          icon: Icons.person_outline,
                          isDark: isDark,
                          controller: _nameController,
                        ),

                        const SizedBox(height: 16),

                        // -------- EMAIL --------
                        _InputField(
                          label: l10n.emailLabel,
                          hint: l10n.emailHint,
                          icon: Icons.mail_outline,
                          isDark: isDark,
                          controller: _emailController,
                        ),

                        const SizedBox(height: 16),

                        // -------- PASSWORD --------
                        _InputField(
                          label: l10n.passwordLabel,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          isDark: isDark,
                          controller: _passwordController,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          l10n.passwordMin,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white54
                                : Colors.black45,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // -------- REGISTER BUTTON --------
                        ElevatedButton(
                          onPressed: _isLoading ? null : registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.registerButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // -------- DIVIDER --------
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black26)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                l10n.continueWith,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black26)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // -------- SOCIAL BUTTONS --------
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading
                                  ? null
                                  : () => registerWithProvider(
                                        AuthProviders.signInWithGoogle),
                                icon: const Icon(Icons.g_mobiledata),
                                label: Text(l10n.google),
                                style: _outlinedStyle(isDark),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading
                                  ? null
                                  : () => registerWithProvider(
                                        AuthProviders.signInWithFacebook),
                                icon: const Icon(Icons.facebook),
                                label: Text(l10n.facebook),
                                style: _outlinedStyle(isDark, facebook: true),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // -------- FOOTER --------
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text.rich(
                              TextSpan(
                                text: l10n.alreadyHaveAccount,
                                children: [
                                  TextSpan(
                                    text: l10n.loginHere,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _outlinedStyle(bool isDark, {bool facebook = false}) {
    return OutlinedButton.styleFrom(
      foregroundColor: facebook
          ? Colors.white
          : (isDark ? Colors.white : Colors.black),
      backgroundColor: facebook
          ? const Color(0xFF1877F2)
          : (isDark ? surfaceDark : surfaceLight),
      side: BorderSide(
        color: facebook
            ? Colors.transparent
            : (isDark ? Colors.white24 : Colors.black12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );
  }
}

/* -------------------- INPUT COMPONENT -------------------- */

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final bool isDark;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    required this.controller,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1C3020) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

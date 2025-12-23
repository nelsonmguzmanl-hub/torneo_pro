import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/auth/auth_providers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;

  /// Simulación: true SOLO si backend lo dice
  bool _isSuspended = false;

  static const Color primaryGreen = Color(0xFF13EC37);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF102213);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1C3020);

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> loginUser() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(l10n.loginEmptyFields);
      return;
    }

    if (!isValidEmail(email)) {
      _showError(l10n.invalidEmail);
      return;
    }

    /*if (password.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }*/

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _redirectUserByRole(credential.user!);

    } on FirebaseAuthException catch (e) {
      String msg = l10n.loginError;
      if (e.code == 'user-not-found') {
        msg = l10n.userNotFound;
      } else if (e.code == 'wrong-password') {
        msg = l10n.wrongPassword;
      }
      _showError(msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _redirectUserByRole(User user) async {
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
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final data = snapshot.data();
    final role = (data is Map<String, dynamic>)
        ? data['role'] ?? 'user'
        : 'user';

    if (!mounted) return;

    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin_home');
    } else {
      Navigator.pushReplacementNamed(context, '/user_home');
    }
  }

  Future<void> loginWithProvider(
    Future<User?> Function() signInMethod) async {

    setState(() => _isLoading = true);

    try {
      final user = await signInMethod();
      if (user != null) {
        await _redirectUserByRole(user);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.loginError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? bgDark : bgLight,
      body: LayoutBuilder(builder: (context, constraints) {
        final isSmallHeight = constraints.maxHeight < 650;

        return SafeArea(
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
                            Navigator.pushReplacementNamed(
                                context, '/language_theme');
                          },
                        ),
                      ],
                    ),
                  ),

                  // ---------------- CONTENT ----------------
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        0,
                        24,
                        MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: isSmallHeight ? 12 : 20),

                          // Logo
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.sports_soccer,
                                size: 40,
                                color: primaryGreen,
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallHeight ? 12 : 20),

                          Text(
                            l10n.loginTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFE0E6E1)
                                  : const Color(0xFF0D1B10),
                            ),
                          ),

                          SizedBox(height: isSmallHeight ? 12 : 20),

                          Text(
                            l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? const Color(0xFFA0B0A5)
                                  : const Color(0xFF4A5D50),
                            ),
                          ),

                          SizedBox(height: isSmallHeight ? 12 : 20),

                          // -------- SUSPENDED WARNING --------
                          if (_isSuspended)
                            Container(
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.report_problem,
                                      color: Colors.red),
                                  SizedBox(height: isSmallHeight ? 12 : 20),
                                  Expanded(
                                    child: Text(
                                      l10n.accountSuspended,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  )
                                ],
                              ),
                            ),

                          // -------- EMAIL --------
                          _InputField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            icon: Icons.mail_outline,
                            isDark: isDark,
                            controller: _emailController,
                          ),

                          SizedBox(height: isSmallHeight ? 12 : 20),

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

                          SizedBox(height: isSmallHeight ? 12 : 20),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/reset-password');
                              },
                              child: Text(
                                l10n.forgotPassword,
                                style: const TextStyle(color: primaryGreen),
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallHeight ? 12 : 20),

                          // -------- LOGIN BUTTON --------
                          ElevatedButton(
                            onPressed: _isLoading ? null : loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(l10n.loginButton,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: isSmallHeight ? 12 : 20),
                                    const Icon(Icons.arrow_forward),
                                  ],
                                ),

                          ),
                          SizedBox(height: isSmallHeight ? 12 : 20),

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
                                        ? const Color(0xFFA0B0A5)
                                        : const Color(0xFF4A5D50),
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

                          SizedBox(height: isSmallHeight ? 12 : 20),

                          // -------- SOCIAL BUTTONS --------
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading
                                    ? null
                                    : () => loginWithProvider(AuthProviders.signInWithGoogle),
                                  icon: const Icon(Icons.g_mobiledata),
                                  label: Text(l10n.google),
                                  style: _outlinedStyle(isDark),
                                ),
                              ),
                              SizedBox(height: isSmallHeight ? 12 : 20),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading
                                    ? null
                                    : () => loginWithProvider(AuthProviders.signInWithFacebook),
                                  icon: const Icon(Icons.facebook),
                                  label: Text(l10n.facebook),
                                  style: _outlinedStyle(isDark),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallHeight ? 12 : 20),

                          // -------- REGISTER --------
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: l10n.noAccount,
                                  children: [
                                    TextSpan(
                                      text: l10n.registerHere,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryGreen,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallHeight ? 12 : 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    )
    );
  }

  ButtonStyle _outlinedStyle(bool isDark) {
    return OutlinedButton.styleFrom(
      foregroundColor:
          isDark ? const Color(0xFFE0E6E1) : const Color(0xFF0D1B10),
      backgroundColor: isDark ? surfaceDark : surfaceLight,
      side: BorderSide(
          color: isDark ? Colors.white24 : Colors.black12),
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
  final TextEditingController? controller;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.suffix,
    this.controller,
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
            color: isDark
                ? const Color(0xFFE0E6E1)
                : const Color(0xFF0D1B10),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: hint.contains('@')
              ? TextInputType.emailAddress
              : TextInputType.text,
          textInputAction: TextInputAction.next,
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

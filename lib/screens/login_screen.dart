import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey           = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword  = true;
  bool _isLoading        = false;
  bool _isGoogleLoading  = false;
  bool _rememberMe       = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final FirebaseAuth  _auth        = FirebaseAuth.instance;
  final GoogleSignIn  _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Email / password login ────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _auth.signInWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _firebaseErrorMessage(e.code));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = "Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google sign-in ────────────────────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() { _isGoogleLoading = true; _errorMessage = null; });
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      if (!mounted) return;
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _firebaseErrorMessage(e.code));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = "Google sign-in failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() =>
      _errorMessage = "Enter your email above first, then tap Forgot password.");
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSnack("Reset link sent to $email ✓", isError: false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _firebaseErrorMessage(e.code));
    }
  }

  // ── Navigation helpers ────────────────────────────────────────────────────
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const HomeScreen()),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const SignupScreen()),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':         return "No account found for this email.";
      case 'wrong-password':         return "Incorrect password. Please try again.";
      case 'invalid-email':          return "The email address is not valid.";
      case 'user-disabled':          return "This account has been disabled.";
      case 'too-many-requests':      return "Too many attempts. Please try again later.";
      case 'network-request-failed': return "Network error. Check your connection.";
      case 'invalid-credential':     return "Invalid credentials. Please try again.";
      default:                       return "Login failed. Please try again.";
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? const Color(0xFFFF5C5C) : const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A07),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildCard(),

                  // ── Inline error banner ──────────────────────────────────
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _buildErrorBanner(_errorMessage!),
                  ],

                  const SizedBox(height: 28),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: "Continue with Google",
                    isLoading: _isGoogleLoading,
                    onTap: _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New to the club?  ",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToSignup,
                        child: const Text(
                          "Request access",
                          style: TextStyle(
                            color: Color(0xFFFF6B2B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFFF6B2B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B2B),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
              child: Text("🏓", style: TextStyle(fontSize: 30))),
        ),
        const SizedBox(height: 20),
        const Text(
          "PINNACLE TT",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1208),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel("Email"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: _inputDecoration(
                  hint: "you@example.com", icon: Icons.email_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Enter your email";
                if (!RegExp(r'^[\w\-.]+@[\w\-]+\.\w+$').hasMatch(v.trim())) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration:
              _inputDecoration(hint: "••••••••", icon: Icons.lock_outline)
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter your password";
                if (v.length < 6) return "Minimum 6 characters";
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? const Color(0xFFFF6B2B)
                              : Colors.transparent,
                          border: Border.all(
                            color: _rememberMe
                                ? const Color(0xFFFF6B2B)
                                : Colors.white30,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: _rememberMe
                            ? const Icon(Icons.check,
                            size: 13, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Remember me",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _handleForgotPassword,
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: Color(0xFFFF6B2B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2B),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.black),
                )
                    : const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C5C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: const Color(0xFFFF5C5C).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF5C5C), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFF5C5C), fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close_rounded,
                color: Color(0xFFFF5C5C), size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white30, size: 20),
      filled: true,
      fillColor: const Color(0xFF140D06),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFFF6B2B), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFFF5C5C), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFFF5C5C), width: 1.2),
      ),
      errorStyle:
      const TextStyle(color: Color(0xFFFF5C5C), fontSize: 11),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: Colors.white.withValues(alpha: 0.1), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "or",
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
          ),
        ),
        Expanded(
            child: Divider(
                color: Colors.white.withValues(alpha: 0.1), height: 1)),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: Colors.white70),
      )
          : Icon(icon, color: Colors.white70, size: 22),
      label: Text(
        label,
        style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF1C1208),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  DateTime? _selectedDob;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B2B),
              onPrimary: Colors.black,
              surface: Color(0xFF1C1208),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1C1208),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      _showError("Please select your date of birth.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _selectedDob!.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'member',
      });

      if (!mounted) return;
      _showSuccess("Account created successfully!");

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const LoginScreen(),
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_firebaseErrorMessage(e.code));
    } catch (e) {
      if (!mounted) return;
      _showError("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "An account already exists with this email.";
      case 'invalid-email':
        return "The email address is not valid.";
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters.";
      case 'network-request-failed':
        return "Network error. Check your connection.";
      default:
        return "Sign up failed. Please try again.";
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF5C5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

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
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildCard(),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already a member?  ",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) => FadeTransition(
                              opacity: animation,
                              child: const LoginScreen(),
                            ),
                            transitionDuration:
                            const Duration(milliseconds: 400),
                          ),
                        ),
                        child: const Text(
                          "Log in",
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          "JOIN PINNACLE TT",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Create your member account",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 13,
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
            _buildLabel("Full Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: _inputDecoration(
                  hint: "John Doe", icon: Icons.person_outline),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Enter your name";
                if (v.trim().length < 2) return "Name too short";
                return null;
              },
            ),
            const SizedBox(height: 20),
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
                final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+\.\w+$');
                if (!emailRegex.hasMatch(v.trim())) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel("Phone Number"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: _inputDecoration(
                  hint: "9876543210", icon: Icons.phone_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Enter your phone number";
                }
                if (v.trim().length < 10) return "Enter a valid phone number";
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel("Date of Birth"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDob,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF140D06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined,
                        color: Colors.white30, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDob == null
                          ? "Select date of birth"
                          : "${_selectedDob!.day.toString().padLeft(2, '0')}/"
                          "${_selectedDob!.month.toString().padLeft(2, '0')}/"
                          "${_selectedDob!.year}",
                      style: TextStyle(
                        color: _selectedDob == null
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white30, size: 20),
                  ],
                ),
              ),
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
                if (v == null || v.isEmpty) return "Enter a password";
                if (v.length < 6) return "Minimum 6 characters";
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel("Confirm Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration:
              _inputDecoration(hint: "••••••••", icon: Icons.lock_outline)
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Confirm your password";
                if (v != _passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
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
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.black),
                )
                    : const Text(
                  "Create Account",
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
      hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.2), fontSize: 14),
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
        borderSide: const BorderSide(color: Color(0xFFFF6B2B), width: 1.5),
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
}
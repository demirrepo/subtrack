import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subtrack/screens/dashboard.dart';
import 'package:subtrack/screens/signup.dart';
import '../services/auth_service.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SigninState();
  }
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final auth = AuthService();
  bool _passwordVisible = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String p) => p.trim().length >= 8;

  // Ensure user doc exists and return it
  Future<Map<String, dynamic>?> _fetchOrCreateUserDoc(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await docRef.get();
    if (snap.exists) return snap.data();

    // create minimal doc
    await auth.createOrUpdateUserDoc(user: user, username: user.displayName);
    final created = await docRef.get();
    return created.exists ? created.data() : null;
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => isLoading = true);
    try {
      final user = await auth.signIn(email, password);
      if (user == null) throw Exception('Sign in returned null user');

      // Ensure Firestore user doc exists
      final userDoc = await _fetchOrCreateUserDoc(user);
      if (kDebugMode) print('User doc after sign-in: $userDoc');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in successful')));

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));
      // TODO: navigate to dashboard / home and pass userDoc if needed
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}')),
      );
      if (kDebugMode) print('Sign in error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      // Make sure your AuthService exposes signInWithGoogle();
      // if your service uses signUpWithGoogle() keep that name instead.
      final user = await auth.signInWithGoogle();
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled')),
        );
        return;
      }

      // Ensure Firestore user doc exists
      final userDoc = await _fetchOrCreateUserDoc(user);
      if (kDebugMode) print('Google user doc: $userDoc');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in successful')),
      );

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));

      // TODO: navigate to dashboard / home
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
      );
      if (kDebugMode) print('Google sign-in error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0EB79E);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF1C1D24),
      body: SafeArea(
        child: Padding(
          // outer padding (same as signup)
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              // form area (aligned to top, horizontally centered)
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LOG IN',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // inner padding matches signup (adds extra horizontal inset)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (v) {
                                    final s = v?.trim() ?? '';
                                    if (s.isEmpty)
                                      return 'Please enter your email';
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(s))
                                      return 'Enter a valid email';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 9),

                                TextFormField(
                                  obscureText: _passwordVisible,
                                  controller: _passwordController,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                      icon:
                                          _passwordVisible
                                              ? const FaIcon(
                                                FontAwesomeIcons.eyeSlash,
                                                color: Colors.white,
                                                size: 17,
                                              )
                                              : const FaIcon(
                                                FontAwesomeIcons.eye,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                    ),
                                    labelText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (v) {
                                    final s = v ?? '';
                                    if (s.isEmpty)
                                      return 'Please enter password';
                                    if (!_isPasswordValid(s))
                                      return 'Password must be at least 8 characters';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                SizedBox(
                                  height: 53,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed:
                                        isLoading ? null : _handleEmailSignIn,
                                    child:
                                        isLoading
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : Text(
                                              'LOG IN',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  'OR',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  height: 53,
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: Image.asset(
                                      'lib/assets/images/google.png',
                                      width: 22,
                                      height: 22,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF272833),
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed:
                                        isLoading ? null : _handleGoogleSignIn,
                                    label:
                                        isLoading
                                            ? const SizedBox.shrink()
                                            : Text(
                                              'LOG IN WITH GOOGLE',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // footer pinned to bottom with same spacing as signup
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Signup()),
                    );
                  },
                  child: Text(
                    'No account yet? Register now.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

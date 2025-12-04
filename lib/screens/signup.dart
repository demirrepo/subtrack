import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:subtrack/screens/signin.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:subtrack/screens/dashboard.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignupState();
  }
}

class _SignupState extends State<Signup> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();
  bool _passwordVisible = true;
  bool isLoading = false;

  bool _isPasswordValid(String p) => p.trim().length >= 8;

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    // VALIDATION first
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields must be filled.")),
      );
      return;
    }

    if (!_isPasswordValid(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ONE sign-up call only
      final user = await auth.signUp(
        email,
        password,
      ); // returns User? from your AuthService
      if (user == null) {
        throw Exception("Sign up failed.");
      }

      // create or update user doc in Firestore
      await auth.createOrUpdateUserDoc(user: user, username: username);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sign up successful")));

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: ${e.toString()}")),
      );
      if (kDebugMode) print("Sign up error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => isLoading = true);
    try {
      final user =
          await auth
              .signUpWithGoogle(); // or signInWithGoogle depending on your service
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-up cancelled")),
        );
        return;
      }

      // create/update Firestore user doc (no username provided for Google)
      await auth.createOrUpdateUserDoc(user: user, username: user.displayName);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google Sign-Up SUCCESS")));

      // TODO: navigate to dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-Up failed: ${e.toString()}")),
      );
      if (kDebugMode) print("Google sign-up error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF1C1D24),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              // Centered, non-scrollable form area
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // keep form compact & centered
                      children: [
                        Text(
                          "SIGN UP",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: TextField(
                            controller: usernameController,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 9),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: TextField(
                            controller: emailController,
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
                          ),
                        ),

                        const SizedBox(height: 9),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: TextField(
                            obscureText: _passwordVisible,
                            controller: passwordController,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: IconButton(
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
                              ),
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            height: 53,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0EB79E),
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: isLoading ? null : _handleEmailSignUp,
                              child:
                                  isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        "SIGN UP",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "OR",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
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
                              onPressed: isLoading ? null : _handleGoogleSignUp,
                              label:
                                  isLoading
                                      ? const SizedBox.shrink()
                                      : Text(
                                        "SIGN UP WITH GOOGLE",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer pinned to the bottom with spacing
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => Signin()));
                  },
                  child: Text(
                    "Already registered? Sign in.",
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

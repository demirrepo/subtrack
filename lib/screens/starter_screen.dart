import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup.dart'; // adjust import path if different

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF1C1D24);
    final accent = const Color(0xFF0EB79E);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 80), // top spacing, tweak if needed
              // Animated title block
              SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "TRACK",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 44,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            "your",
                            style: GoogleFonts.playwriteUsTrad(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Text(
                          "SUBSCRIPTIONS",
                          style: GoogleFonts.poppins(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          SizedBox(width: 30),
                          Image.asset(
                            'lib/assets/images/stpageimage.png',
                            width: 300,
                            height: 300,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Flexible spacer so content stays visually top-centered
              const Spacer(),

              // Optional subtitle / short pitch
              const SizedBox(height: 44),

              // CTA button pinned to bottom area
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: Text(
                      "Create Account",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () {
                      // navigation: replace or push depending on desired flow
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => Signup()));
                    },
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Badge scale + fade
  late final AnimationController _badgeCtrl;
  late final Animation<double> _badgeScale;
  late final Animation<double> _badgeFade;

  // Text fade + slide
  late final AnimationController _textCtrl;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Tagline fade
  late final AnimationController _tagCtrl;
  late final Animation<double> _tagFade;

  // Bottom bar fade
  late final AnimationController _barCtrl;
  late final Animation<double> _barFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ── Badge ────────────────────────────────────────────────────────────
    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.4, end: 1.0));
    _badgeFade = CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));

    // ── Title ────────────────────────────────────────────────────────────
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    // ── Tagline ──────────────────────────────────────────────────────────
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _tagFade = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));

    // ── Bottom bar ───────────────────────────────────────────────────────
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _barFade = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));

    // ── Sequence ─────────────────────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _badgeCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    _tagCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _barCtrl.forward();

    // Navigate after total ~2.4s
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: const LoginScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A07),
      body: Stack(
        children: [
          // ── Ambient glow top-right ──────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6B2B).withOpacity(0.13),
              ),
            ),
          ),
          // ── Ambient glow bottom-left ────────────────────────────────────
          Positioned(
            bottom: 60,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6B2B).withOpacity(0.07),
              ),
            ),
          ),

          // ── Main centred content ────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge
                AnimatedBuilder(
                  animation: _badgeCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _badgeFade.value,
                    child: Transform.scale(
                      scale: _badgeScale.value,
                      child: _buildBadge(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Club name
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: const Text(
                        "PINNACLE TT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                AnimatedBuilder(
                  animation: _tagCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _tagFade.value,
                    child: const Text(
                      "CLUB",
                      style: TextStyle(
                        color: Color(0xFFFF6B2B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom version bar ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _barCtrl,
              builder: (_, __) => Opacity(
                opacity: _barFade.value,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      children: [
                        // Thin orange line
                        Container(
                          width: 36,
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B2B).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "v1.0.0",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1208),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFF6B2B).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B2B).withOpacity(0.25),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Text("🏓", style: TextStyle(fontSize: 46)),
      ),
    );
  }
}
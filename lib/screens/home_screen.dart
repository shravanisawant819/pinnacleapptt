import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'book_table_screen.dart';
import 'rankings_screen.dart';
import 'fees_screen.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const _bg        = Color(0xFF0E0A07);
const _surface   = Color(0xFF1C1208);
const _orange    = Color(0xFFFF6B2B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return "GOOD MORNING";
    if (h < 17) return "GOOD AFTERNOON";
    return "GOOD EVENING";
  }

  Widget _stagger(Widget child, int index) {
    final start = (index * 0.12).clamp(0.0, 0.8);
    final end   = (start + 0.45).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (_, __) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - curve.value)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _orange.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _orange.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stagger(_buildTopBar(), 0),
                  const SizedBox(height: 36),
                  _stagger(_buildGreeting(), 1),
                  const SizedBox(height: 28),
                  _stagger(_buildStatsStrip(), 2),
                  const SizedBox(height: 36),
                  _stagger(_buildSectionLabel("CLUB SERVICES"), 3),
                  const SizedBox(height: 14),
                  _stagger(
                    _buildServiceCard(
                      context,
                      title: "Book Table",
                      subtitle: "Reserve your playing slot instantly",
                      icon: Icons.table_bar_outlined,
                      tag: "POPULAR",
                      page: const BookTableScreen(),
                    ),
                    4,
                  ),
                  _stagger(
                    _buildServiceCard(
                      context,
                      title: "Rankings",
                      subtitle: "See top players in the club",
                      icon: Icons.emoji_events_outlined,
                      page: const RankingsScreen(),
                    ),
                    5,
                  ),
                  _stagger(
                    _buildServiceCard(
                      context,
                      title: "Fees",
                      subtitle: "Check payment status & dues",
                      icon: Icons.payments_outlined,
                      page: const FeesScreen(),
                    ),
                    6,
                  ),
                  _stagger(
                    _buildServiceCard(
                      context,
                      title: "Match Analytics",
                      subtitle: "View performance insights",
                      icon: Icons.insights_outlined,
                      tag: "BETA",
                      page: const Placeholder(),
                    ),
                    7,
                  ),
                  const SizedBox(height: 32),
                  _stagger(_buildUpcomingBanner(), 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text("🏓", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "PINNACLE TT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orange.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: _orange,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _orange,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "What are we\nplaying today?",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.15,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsStrip() {
    return Row(
      children: [
        _buildStatChip(label: "Rank", value: "#12"),
        const SizedBox(width: 10),
        _buildStatChip(label: "Wins", value: "34"),
        const SizedBox(width: 10),
        _buildStatChip(label: "Due", value: "₹0", highlight: true),
      ],
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: highlight ? _orange.withValues(alpha: 0.12) : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight
                ? _orange.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: highlight ? _orange : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.3),
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Widget page,
        String? tag,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: _orange.withValues(alpha: 0.08),
          highlightColor: _orange.withValues(alpha: 0.04),
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => FadeTransition(
                opacity: anim,
                child: page,
              ),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _orange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(icon, color: _orange, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (tag != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: _orange,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _orange.withValues(alpha: 0.85),
            const Color(0xFFD94F10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NEXT MATCH",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Club Championship\nRound 2",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      "Today · 6:00 PM",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text("🏓", style: TextStyle(fontSize: 26)),
            ),
          ),
        ],
      ),
    );
  }
}
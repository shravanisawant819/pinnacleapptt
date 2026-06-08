import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen>
    with SingleTickerProviderStateMixin {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const _bg      = Color(0xFF0E0A07);
  static const _surface = Color(0xFF1C1208);
  static const _orange  = Color(0xFFFF6B2B);

  late final AnimationController _ctrl;

  // ── Data ─────────────────────────────────────────────────────────────────
  final List<_Player> _players = [
    _Player(name: "Rahul",    points: 150, wins: 18, matches: 22, avatar: "R"),
    _Player(name: "Shravani", points: 120, wins: 14, matches: 19, avatar: "S"),
    _Player(name: "Aman",     points: 110, wins: 12, matches: 18, avatar: "A"),
    _Player(name: "Priya",    points:  95, wins: 10, matches: 16, avatar: "P"),
    _Player(name: "Dev",      points:  80, wins:  8, matches: 15, avatar: "D"),
    _Player(name: "Neha",     points:  72, wins:  7, matches: 14, avatar: "N"),
    _Player(name: "Karan",    points:  60, wins:  5, matches: 13, avatar: "K"),
    _Player(name: "Meera",    points:  48, wins:  4, matches: 12, avatar: "M"),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _fade(Widget child, double start) {
    final anim = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, (start + 0.4).clamp(0, 1.0),
          curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - anim.value)),
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
          // Ambient glow
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _orange.withOpacity(0.10),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _fade(_buildAppBar(), 0),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Podium (top 3)
                        _fade(_buildPodium(), 0.05),
                        const SizedBox(height: 32),

                        // Section label
                        _fade(_buildSectionLabel("FULL STANDINGS"), 0.2),
                        const SizedBox(height: 12),

                        // Rest of the list (rank 4+)
                        ...List.generate(_players.length - 3, (i) {
                          return _fade(
                            _buildListTile(_players[i + 3], i + 4),
                            0.25 + i * 0.06,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            "Rankings",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orange.withOpacity(0.25)),
            ),
            child: const Icon(Icons.emoji_events_outlined,
                color: _orange, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Podium ────────────────────────────────────────────────────────────────
  Widget _buildPodium() {
    final first  = _players[0];
    final second = _players[1];
    final third  = _players[2];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          const Text(
            "🏆  TOP PLAYERS",
            style: TextStyle(
              color: _orange,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),

          // Podium columns — 2nd | 1st | 3rd
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildPodiumColumn(second, 2, 80)),
              Expanded(child: _buildPodiumColumn(first,  1, 110)),
              Expanded(child: _buildPodiumColumn(third,  3, 60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(_Player p, int rank, double barHeight) {
    final isFirst = rank == 1;
    final medal = rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉";
    final barColor = rank == 1
        ? _orange
        : rank == 2
        ? const Color(0xFFB0B0B0)
        : const Color(0xFFCD7F32);

    return Column(
      children: [
        // Avatar
        Container(
          width: isFirst ? 62 : 50,
          height: isFirst ? 62 : 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: barColor.withOpacity(0.15),
            border: Border.all(
              color: barColor.withOpacity(0.5),
              width: isFirst ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              p.avatar,
              style: TextStyle(
                color: Colors.white,
                fontSize: isFirst ? 22 : 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          p.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: isFirst ? 13 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${p.points} pts",
          style: TextStyle(
            color: barColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        // Podium block
        Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor.withOpacity(0.12),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: barColor.withOpacity(0.25)),
          ),
          child: Center(
            child: Text(medal, style: const TextStyle(fontSize: 22)),
          ),
        ),
      ],
    );
  }

  // ── Full standings list ────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.3),
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _buildListTile(_Player p, int rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 28,
              child: Text(
                "#$rank",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Avatar circle
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _orange.withOpacity(0.1),
                border: Border.all(color: _orange.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  p.avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + win rate
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${p.wins}W · ${p.matches - p.wins}L · "
                        "${(p.wins / p.matches * 100).toStringAsFixed(0)}% WR",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Points badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _orange.withOpacity(0.2)),
              ),
              child: Text(
                "${p.points} pts",
                style: const TextStyle(
                  color: _orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────
class _Player {
  final String name;
  final int points;
  final int wins;
  final int matches;
  final String avatar;

  const _Player({
    required this.name,
    required this.points,
    required this.wins,
    required this.matches,
    required this.avatar,
  });
}
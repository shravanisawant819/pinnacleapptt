import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen>
    with SingleTickerProviderStateMixin {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const _bg      = Color(0xFF0E0A07);
  static const _surface = Color(0xFF1C1208);
  static const _orange  = Color(0xFFFF6B2B);
  static const _green   = Color(0xFF4CD97B);
  static const _red     = Color(0xFFFF5C5C);

  late final AnimationController _ctrl;
  bool _isPaying = false;

  // ── Fee data ──────────────────────────────────────────────────────────────
  final _monthlyFee   = 2000;
  final _dueDate      = "10th June 2025";
  final _status       = "Pending"; // "Paid" | "Pending" | "Overdue"
  final _memberSince  = "March 2023";

  final List<_FeeRecord> _history = [
    _FeeRecord(month: "May 2025",   amount: 2000, paid: true,  date: "8 May"),
    _FeeRecord(month: "April 2025", amount: 2000, paid: true,  date: "5 Apr"),
    _FeeRecord(month: "March 2025", amount: 2000, paid: true,  date: "9 Mar"),
    _FeeRecord(month: "Feb 2025",   amount: 2000, paid: false, date: "—"),
    _FeeRecord(month: "Jan 2025",   amount: 2000, paid: true,  date: "7 Jan"),
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
      curve: Interval(start, (start + 0.45).clamp(0, 1.0),
          curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - anim.value)),
          child: child,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (_status) {
      case "Paid":    return _green;
      case "Overdue": return _red;
      default:        return _orange;
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case "Paid":    return Icons.check_circle_outline_rounded;
      case "Overdue": return Icons.warning_amber_rounded;
      default:        return Icons.access_time_rounded;
    }
  }

  Future<void> _handlePay() async {
    setState(() => _isPaying = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isPaying = false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSuccessSheet(),
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fade(_buildStatusCard(), 0.05),
                        const SizedBox(height: 16),
                        _fade(_buildStatsRow(), 0.15),
                        const SizedBox(height: 28),
                        _fade(_buildSectionLabel("PAYMENT HISTORY"), 0.22),
                        const SizedBox(height: 12),
                        ...List.generate(_history.length, (i) {
                          return _fade(
                            _buildHistoryTile(_history[i]),
                            0.28 + i * 0.06,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky pay button
          if (_status != "Paid")
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _fade(_buildPayBar(), 0.35),
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
            "Fees",
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
            child: const Icon(Icons.payments_outlined, color: _orange, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Status hero card ──────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _statusColor.withOpacity(0.18),
            _statusColor.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon, color: _statusColor, size: 18),
              const SizedBox(width: 8),
              Text(
                _status.toUpperCase(),
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                _monthlyFee.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Monthly membership fee",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.07),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoChip(Icons.calendar_today_outlined, "Due: $_dueDate"),
              const SizedBox(width: 10),
              _infoChip(Icons.person_outline_rounded, "Since $_memberSince"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white.withOpacity(0.35)),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final paid    = _history.where((r) => r.paid).length;
    final missed  = _history.where((r) => !r.paid).length;
    final streak  = _calcStreak();

    return Row(
      children: [
        _buildStatChip("$paid", "Paid", _green),
        const SizedBox(width: 10),
        _buildStatChip("$missed", "Missed", _red),
        const SizedBox(width: 10),
        _buildStatChip("$streak", "Streak 🔥", _orange),
      ],
    );
  }

  int _calcStreak() {
    int s = 0;
    for (final r in _history) {
      if (r.paid) s++; else break;
    }
    return s;
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
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

  // ── History tile ──────────────────────────────────────────────────────────
  Widget _buildHistoryTile(_FeeRecord r) {
    final color = r.paid ? _green : _red;
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
            // Status dot
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Icon(
                r.paid
                    ? Icons.check_rounded
                    : Icons.close_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),

            // Month
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.month,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.paid ? "Paid on ${r.date}" : "Not paid",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              "₹${r.amount}",
              style: TextStyle(
                color: r.paid ? Colors.white : Colors.white.withOpacity(0.3),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                decoration: r.paid ? null : TextDecoration.lineThrough,
                decorationColor: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pay bar ───────────────────────────────────────────────────────────────
  Widget _buildPayBar() {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _isPaying ? null : _handlePay,
          child: _isPaying
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.black),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payments_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                "Pay ₹$_monthlyFee Now",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Success sheet ─────────────────────────────────────────────────────────
  Widget _buildSuccessSheet() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _green.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _green.withOpacity(0.35)),
            ),
            child: const Icon(Icons.check_rounded, color: _green, size: 32),
          ),
          const SizedBox(height: 18),
          const Text(
            "Payment Successful!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹$_monthlyFee paid for June 2025.\nYou're all clear! 🎉",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "Done",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────
class _FeeRecord {
  final String month;
  final int amount;
  final bool paid;
  final String date;

  const _FeeRecord({
    required this.month,
    required this.amount,
    required this.paid,
    required this.date,
  });
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinnacleapptt/models/booking_model.dart';

class BookTableScreen extends StatefulWidget {
  const BookTableScreen({super.key});

  @override
  State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
  static const _bg      = Color(0xFF0E0A07);
  static const _surface = Color(0xFF1C1208);
  static const _orange  = Color(0xFFFF6B2B);

  DateTime    _selectedDate   = DateTime.now();
  int?        _selectedTable;
  String?     _selectedSlot;
  bool        _isConfirming   = false;
  Set<String> _bookedSlots    = {};
  bool        _isLoadingSlots = false;
  String?     _bookingError;

  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  final List<String> _timeSlots = [
    "06:00 AM", "07:00 AM", "08:00 AM",
    "09:00 AM", "10:00 AM", "11:00 AM",
    "12:00 PM", "01:00 PM", "02:00 PM",
    "03:00 PM", "04:00 PM", "05:00 PM",
    "06:00 PM", "07:00 PM", "08:00 PM",
    "09:00 PM",
  ];

  final int _totalTables = 6;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _loadBookedSlots() async {
    if (_selectedTable == null) return;
    setState(() {
      _isLoadingSlots = true;
      _bookedSlots = {};
    });
    try {
      final snap = await _firestore
          .collection('bookings')
          .where('date',    isEqualTo: _dateKey(_selectedDate))
          .where('tableNo', isEqualTo: _selectedTable)
          .where('status',  isEqualTo: 'Confirmed')
          .get();
      final booked = snap.docs.map((d) => d['timeSlot'] as String).toSet();
      if (mounted) setState(() => _bookedSlots = booked);
    } catch (_) {
      // fail silently
    } finally {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedTable == null || _selectedSlot == null) return;
    setState(() {
      _isConfirming = true;
      _bookingError = null;
    });
    try {
      final user   = _auth.currentUser;
      final docRef = _firestore.collection('bookings').doc();
      final booking = BookingModel(
        id:         docRef.id,
        memberId:   user?.uid ?? 'guest',
        memberName: user?.displayName ?? user?.email ?? 'Guest',
        tableNo:    _selectedTable!,
        date:       _selectedDate,
        timeSlot:   _selectedSlot!,
        status:     'Confirmed',
      );
      await docRef.set({
        ...booking.toMap(),
        'date': _dateKey(_selectedDate),
      });
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _buildSuccessSheet(),
      );
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() =>
        _bookingError = e.message ?? 'Failed to save booking. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return "${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _orange,
            onPrimary: Colors.black,
            surface: Color(0xFF1C1208),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: _bg,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
        _bookedSlots  = {};
        _bookingError = null;
      });
      if (_selectedTable != null) _loadBookedSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBook = _selectedTable != null && _selectedSlot != null;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("SELECT DATE"),
                    const SizedBox(height: 10),
                    _buildDatePicker(),
                    const SizedBox(height: 28),

                    _buildSectionLabel("SELECT TABLE"),
                    const SizedBox(height: 10),
                    _buildTableGrid(),
                    const SizedBox(height: 28),

                    _buildSectionLabel("SELECT TIME SLOT"),
                    const SizedBox(height: 10),

                    if (_selectedTable == null)
                      _buildSelectTableHint()
                    else if (_isLoadingSlots)
                      _buildSlotsLoader()
                    else
                      _buildTimeSlotGrid(),

                    const SizedBox(height: 28),

                    if (_selectedTable != null && _selectedSlot != null)
                      _buildSummaryCard(),

                    if (_bookingError != null) ...[
                      const SizedBox(height: 12),
                      _buildErrorBanner(_bookingError!),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(canBook),
          ],
        ),
      ),
    );
  }

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
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            "Book a Table",
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
              color: _orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orange.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.table_bar_outlined,
                color: _orange, size: 18),
          ),
        ],
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

  Widget _buildDatePicker() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _orange.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  color: _orange, size: 18),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Playing date",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: List.generate(_totalTables, (i) {
        final tableNum   = i + 1;
        final isSelected = _selectedTable == tableNum;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _selectedTable = tableNum;
              _selectedSlot  = null;
              _bookedSlots   = {};
              _bookingError  = null;
            });
            _loadBookedSlots();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? _orange.withValues(alpha: 0.15)
                  : _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? _orange
                    : Colors.white.withValues(alpha: 0.07),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_bar_rounded,
                  color: isSelected
                      ? _orange
                      : Colors.white.withValues(alpha: 0.35),
                  size: 22,
                ),
                const SizedBox(height: 5),
                Text(
                  "Table $tableNum",
                  style: TextStyle(
                    color: isSelected
                        ? _orange
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectTableHint() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Text(
        "Select a table first to see available slots",
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSlotsLoader() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _orange),
          ),
          const SizedBox(width: 12),
          Text(
            "Checking availability...",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: _timeSlots.map((slot) {
        final isBooked   = _bookedSlots.contains(slot);
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isBooked
              ? null
              : () {
            setState(() {
              _selectedSlot = slot;
              _bookingError = null;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.white.withValues(alpha: 0.02)
                  : isSelected
                  ? _orange.withValues(alpha: 0.15)
                  : _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isBooked
                    ? Colors.white.withValues(alpha: 0.04)
                    : isSelected
                    ? _orange
                    : Colors.white.withValues(alpha: 0.07),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isBooked
                    ? Colors.white.withValues(alpha: 0.15)
                    : isSelected
                    ? _orange
                    : Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
                decoration: isBooked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.white24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined,
              color: _orange, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Booking Summary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_formatDate(_selectedDate)}  ·  Table $_selectedTable  ·  $_selectedSlot",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C5C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFFF5C5C).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF5C5C), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Color(0xFFFF5C5C), fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _bookingError = null),
            child: const Icon(Icons.close_rounded,
                color: Color(0xFFFF5C5C), size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool canBook) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.05))),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      child: Row(
        children: [
          Row(
            children: [
              _legendDot(_orange, "Available"),
              const SizedBox(width: 12),
              _legendDot(Colors.white24, "Booked"),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canBook ? _orange : _surface,
              foregroundColor:
              canBook ? Colors.black : Colors.white38,
              elevation: 0,
              minimumSize: const Size(140, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed:
            canBook && !_isConfirming ? _confirmBooking : null,
            child: _isConfirming
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.black),
            )
                : Text(
              canBook ? "Confirm Booking" : "Select Slot",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSheet() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1208),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _orange.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.check_rounded,
                color: _orange, size: 32),
          ),
          const SizedBox(height: 18),
          const Text(
            "Table Booked!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_formatDate(_selectedDate)}\nTable $_selectedTable  ·  $_selectedSlot",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
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
                backgroundColor: _orange,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "Done",
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
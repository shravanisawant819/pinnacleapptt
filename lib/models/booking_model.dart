class BookingModel {
  final String id;
  final String memberId;
  final String memberName;
  int tableNo;
  DateTime date;
  String timeSlot;
  String status; // "Confirmed" | "Cancelled" | "Completed"
  DateTime createdAt;

  BookingModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.tableNo,
    required this.date,
    required this.timeSlot,
    this.status = "Confirmed",
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Computed ──────────────────────────────────────────────────────────────

  /// True if the booking is for today or a future date
  bool get isUpcoming =>
      date.isAfter(DateTime.now()) ||
          _isSameDay(date, DateTime.now());

  /// True if the booking has been cancelled
  bool get isCancelled => status == "Cancelled";

  /// True if the booking is confirmed and upcoming
  bool get isActive => status == "Confirmed" && isUpcoming;

  /// Formatted date string — e.g. "Mon, 10 Jun 2025"
  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  /// Short display label — e.g. "Table 3 · 06:00 PM"
  String get displayLabel => "Table $tableNo · $timeSlot";

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      "id":          id,
      "memberId":    memberId,
      "memberName":  memberName,
      "tableNo":     tableNo,
      "date":        date.toIso8601String(),
      "timeSlot":    timeSlot,
      "status":      status,
      "createdAt":   createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id:         map["id"]         as String,
      memberId:   map["memberId"]   as String,
      memberName: map["memberName"] as String,
      tableNo:    map["tableNo"]    as int,
      date:       DateTime.parse(map["date"] as String),
      timeSlot:   map["timeSlot"]   as String,
      status:     map["status"]     as String? ?? "Confirmed",
      createdAt:  DateTime.parse(map["createdAt"] as String),
    );
  }

  BookingModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    int? tableNo,
    DateTime? date,
    String? timeSlot,
    String? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id:         id         ?? this.id,
      memberId:   memberId   ?? this.memberId,
      memberName: memberName ?? this.memberName,
      tableNo:    tableNo    ?? this.tableNo,
      date:       date       ?? this.date,
      timeSlot:   timeSlot   ?? this.timeSlot,
      status:     status     ?? this.status,
      createdAt:  createdAt  ?? this.createdAt,
    );
  }

  /// Cancel this booking and return an updated copy
  BookingModel cancel() => copyWith(status: "Cancelled");

  /// Mark this booking as completed
  BookingModel complete() => copyWith(status: "Completed");

  @override
  String toString() {
    return 'BookingModel(id: $id, member: $memberName, '
        'table: $tableNo, date: $formattedDate, slot: $timeSlot, status: $status)';
  }
}
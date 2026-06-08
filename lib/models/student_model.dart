class MemberModel {
  final String id;
  String name;
  String email;
  String phone;
  String avatarInitial;

  // Membership
  String membershipStatus; // "Active" | "Pending" | "Expired"
  DateTime joinDate;

  // Attendance
  int totalSessions;
  int attendedSessions;

  MemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinDate,
    String? avatarInitial,
    this.membershipStatus = "Active",
    this.totalSessions = 0,
    this.attendedSessions = 0,
  }) : avatarInitial = avatarInitial ?? (name.isNotEmpty ? name[0].toUpperCase() : "?");

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Attendance percentage (0–100). Returns 0 if no sessions recorded.
  double get attendancePercent =>
      totalSessions == 0 ? 0 : (attendedSessions / totalSessions) * 100;

  /// Missed sessions count
  int get missedSessions => totalSessions - attendedSessions;

  /// True if membership is currently active
  bool get isActive => membershipStatus == "Active";

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      "id":                id,
      "name":              name,
      "email":             email,
      "phone":             phone,
      "avatarInitial":     avatarInitial,
      "membershipStatus":  membershipStatus,
      "joinDate":          joinDate.toIso8601String(),
      "totalSessions":     totalSessions,
      "attendedSessions":  attendedSessions,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id:               map["id"] as String,
      name:             map["name"] as String,
      email:            map["email"] as String,
      phone:            map["phone"] as String,
      avatarInitial:    map["avatarInitial"] as String?,
      membershipStatus: map["membershipStatus"] as String? ?? "Active",
      joinDate:         DateTime.parse(map["joinDate"] as String),
      totalSessions:    map["totalSessions"] as int? ?? 0,
      attendedSessions: map["attendedSessions"] as int? ?? 0,
    );
  }

  /// Returns a copy with updated fields (immutable-style update)
  MemberModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarInitial,
    String? membershipStatus,
    DateTime? joinDate,
    int? totalSessions,
    int? attendedSessions,
  }) {
    return MemberModel(
      id:               id               ?? this.id,
      name:             name             ?? this.name,
      email:            email            ?? this.email,
      phone:            phone            ?? this.phone,
      avatarInitial:    avatarInitial    ?? this.avatarInitial,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      joinDate:         joinDate         ?? this.joinDate,
      totalSessions:    totalSessions    ?? this.totalSessions,
      attendedSessions: attendedSessions ?? this.attendedSessions,
    );
  }

  @override
  String toString() {
    return 'MemberModel(id: $id, name: $name, status: $membershipStatus, '
        'attendance: ${attendancePercent.toStringAsFixed(1)}%)';
  }
}
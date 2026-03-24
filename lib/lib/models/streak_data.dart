class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String? lastActiveDate;
  final Set<String> activeDays;

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    Set<String>? activeDays,
  }) : activeDays = activeDays ?? {};

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDate,
    Set<String>? activeDays,
  }) =>
      StreakData(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        activeDays: activeDays ?? this.activeDays,
      );

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': lastActiveDate,
        'activeDays': activeDays.toList(),
      };

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastActiveDate: json['lastActiveDate'] as String?,
        activeDays: Set<String>.from(
          (json['activeDays'] as List? ?? []).map((e) => e.toString()),
        ),
      );
}

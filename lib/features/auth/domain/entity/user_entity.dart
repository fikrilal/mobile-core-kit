class UserEntity {
  String? id;
  String? email;
  String? displayName;
  String? username;
  String? timezone;
  String? profileVisibility;
  bool? emailVerified;
  String? createdAt;
  String? avatarUrl;
  String? country;
  String? bio;
  List<String>? preferredGenres;
  String? dailyReadingIntention;
  String? preferredReminderTime;
  bool? enableDailyReminders;
  List<int>? reminderDays;
  bool? weeklyRecapEnabled;
  String? weeklyRecapTime;
  bool? remindersEmail;
  bool? remindersPush;
  bool? weeklyRecapEmail;
  bool? weeklyRecapPush;
  String? accessToken;
  String? refreshToken;
  int? expiresIn;

  UserEntity({
    this.id,
    this.email,
    this.displayName,
    this.username,
    this.timezone,
    this.profileVisibility,
    this.emailVerified,
    this.createdAt,
    this.avatarUrl,
    this.country,
    this.bio,
    this.preferredGenres,
    this.dailyReadingIntention,
    this.preferredReminderTime,
    this.enableDailyReminders,
    this.reminderDays,
    this.weeklyRecapEnabled,
    this.weeklyRecapTime,
    this.remindersEmail,
    this.remindersPush,
    this.weeklyRecapEmail,
    this.weeklyRecapPush,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? username,
    String? timezone,
    String? profileVisibility,
    bool? emailVerified,
    String? createdAt,
    String? avatarUrl,
    String? country,
    String? bio,
    List<String>? preferredGenres,
    String? dailyReadingIntention,
    String? preferredReminderTime,
    bool? enableDailyReminders,
    List<int>? reminderDays,
    bool? weeklyRecapEnabled,
    String? weeklyRecapTime,
    bool? remindersEmail,
    bool? remindersPush,
    bool? weeklyRecapEmail,
    bool? weeklyRecapPush,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      timezone: timezone ?? this.timezone,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      preferredGenres: preferredGenres ?? this.preferredGenres,
      dailyReadingIntention:
          dailyReadingIntention ?? this.dailyReadingIntention,
      preferredReminderTime:
          preferredReminderTime ?? this.preferredReminderTime,
      enableDailyReminders: enableDailyReminders ?? this.enableDailyReminders,
      reminderDays: reminderDays ?? this.reminderDays,
      weeklyRecapEnabled: weeklyRecapEnabled ?? this.weeklyRecapEnabled,
      weeklyRecapTime: weeklyRecapTime ?? this.weeklyRecapTime,
      remindersEmail: remindersEmail ?? this.remindersEmail,
      remindersPush: remindersPush ?? this.remindersPush,
      weeklyRecapEmail: weeklyRecapEmail ?? this.weeklyRecapEmail,
      weeklyRecapPush: weeklyRecapPush ?? this.weeklyRecapPush,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }
}

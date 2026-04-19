class UserSettings {
  final String userID;
  final bool darkMode;
  final bool twoFactorEnabled;
  final String language;

  UserSettings({
    required this.userID,
    this.darkMode = false,
    this.twoFactorEnabled = false,
    this.language = 'English',
  });

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'darkMode': darkMode,
      'twoFactorEnabled': twoFactorEnabled,
      'language': language,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userID: map['userID'] as String,
      darkMode: map['darkMode'] as bool? ?? false,
      twoFactorEnabled: map['twoFactorEnabled'] as bool? ?? false,
      language: map['language'] as String? ?? 'English',
    );
  }

  UserSettings copyWith({
    bool? darkMode,
    bool? twoFactorEnabled,
    String? language,
  }) {
    return UserSettings(
      userID: userID,
      darkMode: darkMode ?? this.darkMode,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      language: language ?? this.language,
    );
  }
}

class UserSettings {
  final String userID;
  final bool darkMode;
  final bool twoFactorEnabled;
  final String language;
  final String? totpSecret;

  UserSettings({
    required this.userID,
    this.darkMode = false,
    this.twoFactorEnabled = false,
    this.language = 'English',
    this.totpSecret,
  });

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'darkMode': darkMode,
      'twoFactorEnabled': twoFactorEnabled,
      'language': language,
      'totpSecret': totpSecret,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userID: map['userID'] as String,
      darkMode: map['darkMode'] as bool? ?? false,
      twoFactorEnabled: map['twoFactorEnabled'] as bool? ?? false,
      language: map['language'] as String? ?? 'English',
      totpSecret: map['totpSecret'] as String?,
    );
  }

  UserSettings copyWith({
    bool? darkMode,
    bool? twoFactorEnabled,
    String? language,
    Object? totpSecret = _sentinel,
  }) {
    return UserSettings(
      userID: userID,
      darkMode: darkMode ?? this.darkMode,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      language: language ?? this.language,
      totpSecret: totpSecret == _sentinel
          ? this.totpSecret
          : totpSecret as String?,
    );
  }
}

// Sentinel so copyWith can distinguish "not provided" from "explicitly null".
const Object _sentinel = Object();

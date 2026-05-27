// lib/models/seeker_profile.dart

class SeekerProfile {
  String name;
  bool anonymousMode;
  Map<String, bool> settings;

  SeekerProfile({
    required this.name,
    this.anonymousMode = true,
    required this.settings,
  });

  factory SeekerProfile.fromJson(Map<String, dynamic> json) {
    return SeekerProfile(
      name: json['name'] ?? 'Anonymous Seeker',
      anonymousMode:
          json['anonymous_mode'] == 1 || json['anonymous_mode'] == true,
      settings: json['settings'] != null
          ? Map<String, bool>.from(json['settings'])
          : {},
    );
  }
}

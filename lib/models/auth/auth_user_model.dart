import 'college_model.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String status;
  final bool emailVerified;
  final College? college;
  final String? organization;
  final List<String> fcmTokens;
  final String timezone;
  final bool? isGoogleLinked;
  final String createdAt;
  final String updatedAt;
  final String? lastLogin;
  final String? lastLoginIP;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    required this.status,
    required this.emailVerified,
    this.college,
    this.organization,
    required this.fcmTokens,
    required this.timezone,
    this.isGoogleLinked,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.lastLoginIP,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
<<<<<<< Updated upstream
=======
    print("🏫 [AuthUser.fromJson] Raw input: $json");
    print("🏫 Parsing college field: ${json['college']}");

    final idValue = json['_id'] as String? ?? json['id'] as String? ?? '';
    final nameValue = json['name'] as String? ?? '';
    final emailValue = json['email'] as String? ?? '';
    final roleValue = json['role'] as String? ?? '';
    final avatarValue = json['avatar'] as String?;
    final statusValue = json['status'] as String? ?? 'active';
    final emailVerifiedValue = json['emailVerified'] as bool? ?? false;
    
    final organizationValue = json['organization'] as String?;
    final timezoneValue = json['timezone'] as String? ?? 'Asia/Kolkata';
    final isGoogleLinkedValue = json['isGoogleLinked'] as bool?;
    final createdAtValue = json['createdAt'] as String? ?? '';
    final updatedAtValue = json['updatedAt'] as String? ?? '';
    final lastLoginValue = json['lastLogin'] as String?;
    final lastLoginIPValue = json['lastLoginIP'] as String?;

    List<String> fcmTokensList = [];
    if (json['fcmTokens'] != null) {
      try {
        if (json['fcmTokens'] is List) {
          fcmTokensList = (json['fcmTokens'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
        }
      } catch (e) {
        print("⚠️ [AuthUser.fromJson] FCM tokens parse error: $e");
      }
    }

    College? collegeValue;
    if (json['college'] != null && json['college'] is Map<String, dynamic>) {
      try {
        collegeValue = College.fromJson(json['college'] as Map<String, dynamic>);
      } catch (e) {
        print("⚠️ [AuthUser.fromJson] College parse error: $e");
      }
    }

>>>>>>> Stashed changes
    return AuthUser(
      id: idValue,
      name: nameValue,
      email: emailValue,
      role: roleValue,
      avatar: avatarValue,
      status: statusValue,
      emailVerified: emailVerifiedValue,
      college: collegeValue,
      organization: organizationValue,
      fcmTokens: fcmTokensList,
      timezone: timezoneValue,
      isGoogleLinked: isGoogleLinkedValue,
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
      lastLogin: lastLoginValue,
      lastLoginIP: lastLoginIPValue,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'role': role,
    'avatar': avatar,
    'status': status,
    'emailVerified': emailVerified,
    'college': college?.toJson(),
    'organization': organization,
    'fcmTokens': fcmTokens,
    'timezone': timezone,
    'isGoogleLinked': isGoogleLinked,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'lastLogin': lastLogin,
    'lastLoginIP': lastLoginIP,
  };
}

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String status;
  final bool emailVerified;
  final String? college;
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
    return AuthUser(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      status: json['status'] as String? ?? 'active',
      emailVerified: json['emailVerified'] as bool? ?? false,
      college: json['college'] as String?,
      organization: json['organization'] as String?,
      fcmTokens: (json['fcmTokens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      isGoogleLinked: json['isGoogleLinked'] as bool?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      lastLogin: json['lastLogin'] as String?,
      lastLoginIP: json['lastLoginIP'] as String?,
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
        'college': college,
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

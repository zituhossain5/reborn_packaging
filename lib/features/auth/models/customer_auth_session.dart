class CustomerAuthSession {
  const CustomerAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final String idToken;
  final DateTime expiresAt;

  bool get isExpired => expiresAt.isBefore(
    DateTime.now().toUtc().add(const Duration(seconds: 30)),
  );

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory CustomerAuthSession.fromJson(Map<String, dynamic> json) {
    return CustomerAuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      idToken: json['idToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String).toUtc(),
    );
  }
}

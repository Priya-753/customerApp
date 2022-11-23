class AuthToken {
  final int? id;
  final String? accessToken;
  final String? refreshToken;
  final int createdTime;

  AuthToken({
    this.id,
    required this.accessToken,
    required this.refreshToken,
    required this.createdTime
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
        id: json['id'],
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        createdTime: json['created_time'] ?? DateTime.now().millisecondsSinceEpoch);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'created_time': createdTime
    };
  }
}

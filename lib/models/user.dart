/// User model with all required fields for the catering app.
enum Kelas { x, xi, xii }

enum Jurusan { rpl, dkv, anm, bc, tkj, gd }

/// Role pengguna aplikasi. `admin` untuk pengelola katering (website admin).
enum UserRole { user, admin }

extension UserRoleExtension on UserRole {
  String get label => switch (this) {
        UserRole.user => 'user',
        UserRole.admin => 'admin',
      };

  static UserRole fromLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}

extension KelasExtension on Kelas {
  String get label => switch (this) {
        Kelas.x => 'X',
        Kelas.xi => 'XI',
        Kelas.xii => 'XII',
      };

  static Kelas fromLabel(String label) {
    try {
      return switch (label.toUpperCase()) {
        'X' => Kelas.x,
        'XI' => Kelas.xi,
        'XII' => Kelas.xii,
        _ => Kelas.x,
      };
    } catch (_) {
      return Kelas.x;
    }
  }
}

extension JurusanExtension on Jurusan {
  String get label => switch (this) {
        Jurusan.rpl => 'RPL',
        Jurusan.dkv => 'DKV',
        Jurusan.anm => 'ANM',
        Jurusan.bc => 'BC',
        Jurusan.tkj => 'TKJ',
        Jurusan.gd => 'GD',
      };

  static Jurusan fromLabel(String label) {
    try {
      return switch (label.toUpperCase()) {
        'RPL' => Jurusan.rpl,
        'DKV' => Jurusan.dkv,
        'ANM' => Jurusan.anm,
        'BC' => Jurusan.bc,
        'TKJ' => Jurusan.tkj,
        'GD' => Jurusan.gd,
        _ => Jurusan.rpl,
      };
    } catch (_) {
      return Jurusan.rpl;
    }
  }
}

/// Main user model for the app.
class AppUser {
  final String uid;
  final String username;
  final String phone;
  final String name;
  final Jurusan jurusan;
  final Kelas kelas;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.username,
    required this.phone,
    required this.name,
    required this.jurusan,
    required this.kelas,
    this.role = UserRole.user,
    this.photoUrl,
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<dynamic, dynamic> map) => AppUser(
        uid: uid,
        username: map['username'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        name: map['name'] as String? ?? '',
        jurusan: map['jurusan'] != null
            ? JurusanExtension.fromLabel(map['jurusan'] as String)
            : Jurusan.rpl,
        kelas: map['kelas'] != null
            ? KelasExtension.fromLabel(map['kelas'] as String)
            : Kelas.x,
        role: UserRoleExtension.fromLabel(map['role'] as String?),
        photoUrl: map['photoUrl'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'username': username,
        'phone': phone,
        'name': name,
        'jurusan': jurusan.label,
        'kelas': kelas.label,
        'role': role.label,
        'photoUrl': photoUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  /// Copy with method for updates
  AppUser copyWith({
    String? username,
    String? phone,
    String? name,
    Jurusan? jurusan,
    Kelas? kelas,
    UserRole? role,
    String? photoUrl,
  }) => AppUser(
        uid: uid,
        username: username ?? this.username,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        jurusan: jurusan ?? this.jurusan,
        kelas: kelas ?? this.kelas,
        role: role ?? this.role,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
      );

  bool get isAdmin => role == UserRole.admin;
}
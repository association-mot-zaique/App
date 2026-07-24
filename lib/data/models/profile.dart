/// A user profile (A-11): one device can be shared between several people,
/// each with their own classeur and settings.
class Profile {
  const Profile({required this.id, required this.name});

  /// Id of the historical, single-user profile. It keeps the legacy storage
  /// locations so existing classeurs and settings are preserved as-is.
  static const String defaultId = 'default';

  final String id;
  final String name;

  bool get isDefault => id == defaultId;

  Profile copyWith({String? name}) => Profile(id: id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
  );
}

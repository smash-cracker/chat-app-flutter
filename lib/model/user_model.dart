class UserModel {
  final String name;
  final String phone;
  final String dp;
  final bool isOnline;
  final List<String> groupIDs;

  UserModel({
    required this.name,
    required this.phone,
    required this.dp,
    required this.isOnline,
    required this.groupIDs,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'dp': dp,
      'isOnline': isOnline,
      'groupIDs': groupIDs,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      dp: map['dp'] ?? '',
      isOnline: map['isOnline'] ?? '',
      groupIDs: List<String>.from(
        map['groupIDs'],
      ),
    );
  }
}

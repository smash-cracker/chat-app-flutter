class ChatContact {
  final String name;
  final String profilePic;
  final String contactID;
  final DateTime timeSent;
  final String lastMessage;

  ChatContact({
    required this.name,
    required this.profilePic,
    required this.contactID,
    required this.timeSent,
    required this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactID': contactID,
      'timeSent': timeSent,
      'lastMessage': lastMessage,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      contactID: map['contactID'] ?? '',
      timeSent: map['timeSent'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
    );
  }
}

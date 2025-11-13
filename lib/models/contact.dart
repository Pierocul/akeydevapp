class Contact {
  final String id;
  final String name;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const Contact({
    required this.id,
    required this.name,
    this.lastMessage,
    this.lastMessageAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.millisecondsSinceEpoch,
    };
  }

  factory Contact.fromMap(String id, Map<String, dynamic> data) {
    return Contact(
      id: id,
      name: (data['name'] as String?) ?? 'Contacto',
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: data['lastMessageAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['lastMessageAt'] as num).toInt(),
            )
          : null,
    );
  }
}



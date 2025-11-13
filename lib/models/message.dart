class Message {
  final String id;
  final String text;
  final String sender; // 'me' o 'contact'
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> data) {
    return Message(
      id: id,
      text: (data['text'] as String?) ?? '',
      sender: (data['sender'] as String?) ?? 'me',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        ((data['createdAt'] as num?) ?? DateTime.now().millisecondsSinceEpoch)
            .toInt(),
      ),
    );
  }
}



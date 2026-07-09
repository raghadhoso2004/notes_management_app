class Note {
  int? id;
  String? firebaseId;
  String userId; // ⭐ مهم جدًا (كل مستخدم له بياناته)
  String title;
  String content;
  String createdAt;
  String updatedAt;
  bool isSynced;

  Note({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // 🔹 تحويل إلى Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // 🔹 قراءة من SQLite
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      firebaseId: map['firebaseId'],
      userId: map['userId'] ?? '',
      title: map['title'],
      content: map['content'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isSynced: map['isSynced'] == 1,
    );
  }

  // 🔹 إرسال إلى Firestore
  Map<String, dynamic> toFirestore(String userId) {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _createSortedChatId(String user1Id, String user2Id) {
    List<String> participants = [user1Id, user2Id]..sort();
    return participants
        .join('_'); // You might not need to use the ID as the doc ID
  }

  Future<String> getOrCreateChat(String user1Id, String user2Id) async {
    final sortedParticipants = [user1Id, user2Id]..sort();
    final query = await _firestore
        .collection('chats')
        .where('participantIds', isEqualTo: sortedParticipants)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id; // Existing chat
    } else {
      final doc = await _firestore.collection('chats').add({
        'participantIds': sortedParticipants,
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
      });
      return doc.id; // New chat
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.now(),
    });

    // Update last message in chat preview
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'lastMessageTime': Timestamp.now(),
    });
  }

  // Stream messages for a chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}

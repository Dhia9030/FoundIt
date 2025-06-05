//hedha zeda juste tastit bih lfront

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foundita/services/chat_service.dart';
import '../models/conversation.dart';

class ConversationProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;
  final ChatService _chatService = ChatService();
  String? _currentChatId;
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChatId => _currentChatId;
  Future<void> fetchConversations(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(
          seconds: 1)); // Consider removing this delay in production

      // Mock data - in real app, this would come from backend
      _conversations = [
        Conversation(
          id: '1',
          notificationId: '1',
          participant1Id: 'user1',
          participant2Id: 'user2',
          itemId: '1',
          messages: [
            Message(
              id: '1',
              senderId: 'user1',
              content: 'Hello, I think I found your wallet!',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            )
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content, String senderId) async {
    if (_currentChatId == null) {
      print('Error: Attempted to send message before chat ID was set.');
      return;
    }
    await _chatService.sendMessage(
      chatId: _currentChatId!,
      senderId: senderId,
      content: content,
    );
  }

  void handleIncomingMessage(Message message, String conversationId) {
    _conversations = _conversations.map((c) {
      if (c.id == conversationId) {
        return Conversation(
          id: c.id,
          notificationId: c.notificationId,
          participant1Id: c.participant1Id,
          participant2Id: c.participant2Id,
          itemId: c.itemId,
          messages: [...c.messages, message],
          createdAt: c.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return c;
    }).toList();
    notifyListeners();
  }

  Future<void> startChat(String user1Id, String user2Id) async {
    // Only fetch/create chat ID if it's not already set
    if (_currentChatId == null || _currentChatId!.isEmpty) {
      _currentChatId = await _chatService.getOrCreateChat(user1Id, user2Id);
      notifyListeners(); // Notify listeners that _currentChatId has changed
    }
  }

  Stream<QuerySnapshot> get messages {
    if (_currentChatId == null || _currentChatId!.isEmpty) {
      return const Stream.empty();
    }
    return _chatService.getMessages(_currentChatId!);
  }
}

import 'package:firebase_database/firebase_database.dart';

class HomeChatEntity {
  final String partnerId;
  final String partnerName;
  final String lastMessage;
  final String lastMessageSenderId;
  final String chatRoomId;
  final bool isTyping;
  int unreadCount;
  final int timestamp;

  HomeChatEntity({
    required this.partnerId,
    required this.partnerName,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.chatRoomId,
    required this.isTyping,
    required this.unreadCount,
    required this.timestamp,
  });
}

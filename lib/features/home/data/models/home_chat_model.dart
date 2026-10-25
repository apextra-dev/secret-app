import 'package:secret/features/home/domain/entities/home_chat_entity.dart';

class HomeChatModel extends HomeChatEntity {
  HomeChatModel({
    required super.partnerId,
    required super.partnerName,
    required super.lastMessage,
    required super.lastMessageSenderId,
    required super.chatRoomId,
    required super.timestamp,
    required super.isTyping,
    required super.unreadCount,
  });

  factory HomeChatModel.fromMap(Map<String, dynamic> map) {
    return HomeChatModel(
      partnerId: map['partnerId'] ?? '',
      partnerName: map['partnerName'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      timestamp: map['timestamp'] is int ? map['timestamp'] as int : (map['timestamp'] is Map ? 0 : 0),
      isTyping: map['isTyping'] ?? false,
      unreadCount: map['undreadCount'] ?? 0,
    );
  }
}

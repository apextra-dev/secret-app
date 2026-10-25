import 'package:secret/features/presence/data/entities/partner_presence_entity.dart';

abstract class ChatRepository {
  Future<void> sendMessage(
    String chatRoomId,
    String partnerId,
    String partnerName,
    String senderId,
    String text,
  );

  Future<void> resetCounter(String partnerId, String myId);

  Future<void> updateTypingStatus(String myId, String partnerId, bool isTyping);

  Stream<PartnerPresenceEntitiy> getUserState(String partnerId, String myId);
}

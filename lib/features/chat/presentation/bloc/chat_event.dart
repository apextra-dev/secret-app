import 'package:secret/features/home/presentation/bloc/home_chat_event.dart';
import 'package:secret/features/presence/data/entities/partner_presence_entity.dart';

abstract class ChatEvent {}

class SendMessage extends ChatEvent {
  String chatRoomId;
  String partnerId;
  String partnerName;
  String senderId;
  String text;

  SendMessage({
    required this.chatRoomId,
    required this.partnerId,
    required this.partnerName,
    required this.senderId,
    required this.text,
  });
}

class GetPartnerStatus extends ChatEvent {
  String partnerId;
  String myId;

  GetPartnerStatus({required this.partnerId, required this.myId});
}

class UpdatePartnerStatus extends ChatEvent {
  final PartnerPresenceEntitiy presence;

  UpdatePartnerStatus(this.presence);
}

class OnTypingChanged extends ChatEvent {
  String myId;
  String partnerId;
  String text;

  OnTypingChanged({
    required this.myId,
    required this.partnerId,
    required this.text,
  });
}

class ResetCounter extends ChatEvent {
  String partnerId;
  String myId;

  ResetCounter({required this.partnerId, required this.myId});
}

class GetUnreadCount extends HomeChatEvent {
  String myId;
  String partnerId;

  GetUnreadCount({required this.myId, required this.partnerId});
}

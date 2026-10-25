import 'package:secret/features/presence/data/entities/partner_presence_entity.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ReturnUserStatus extends ChatState {
  final PartnerPresenceEntitiy presence;
  final bool isTextNotEmpty;

  ReturnUserStatus({required this.presence, required this.isTextNotEmpty});
}

class ChatFailure extends ChatState {
  String message;

  ChatFailure({required this.message});
}

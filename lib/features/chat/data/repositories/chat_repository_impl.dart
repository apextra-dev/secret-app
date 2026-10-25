import 'package:secret/features/chat/data/data_sources/chat_data_source.dart';
import 'package:secret/features/chat/domain/repositories/chat_repository.dart';
import 'package:secret/features/presence/data/entities/partner_presence_entity.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource _dataSource;

  ChatRepositoryImpl({required this._dataSource});

  @override
  Future<void> sendMessage(
    String chatRoomId,
    String partnerId,
    String partnerName,
    String senderId,
    String text,
  ) async {
    await _dataSource.sendMessage(
      chatRoomId,
      partnerId,
      partnerName,
      senderId,
      text,
    );
  }

  @override
  Future<void> updateTypingStatus(
    String myId,
    String partnerId,
    bool isTyping,
  ) async {
    await _dataSource.updateTypingStatus(myId, partnerId, isTyping);
  }

  @override
  Future<void> resetCounter(String partnerId, String myId) async {
    await _dataSource.resetCounter(partnerId, myId);
  }

  @override
  Stream<PartnerPresenceEntitiy> getUserState(String partnerId, String myId) {
    return _dataSource.getUserStatus(partnerId, myId);
  }
}

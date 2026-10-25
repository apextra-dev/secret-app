import 'package:secret/features/home/domain/entities/home_chat_entity.dart';

abstract class HomeChatRepository {
  Stream<List<HomeChatEntity>> getChatList();
}
import 'package:secret/features/home/data/data_sources/home_chat_data_source.dart';
import 'package:secret/features/home/domain/entities/home_chat_entity.dart';
import 'package:secret/features/home/domain/repositories/home_chat_repository.dart';

class HomeChatRepoitoryImpl implements HomeChatRepository {

  final HomeChatDataSource _chatDataSource;

  HomeChatRepoitoryImpl({required this._chatDataSource});

  @override
  Stream<List<HomeChatEntity>> getChatList() {
    return _chatDataSource.getChatsStream();
  }
}
import 'package:secret/features/home/domain/entities/home_chat_entity.dart';

abstract class HomeChatState {}

class HomeChatInitial extends HomeChatState {}

class HomeChatsLoading extends HomeChatState {}

class HomeChatsLoaded extends HomeChatState {
  List<HomeChatEntity> chats;

  HomeChatsLoaded({required this.chats});
}

class HomeChatFailure extends HomeChatState {
  String message;

  HomeChatFailure({required this.message});
}
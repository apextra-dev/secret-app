import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret/features/home/domain/repositories/home_chat_repository.dart';
import 'package:secret/features/home/presentation/bloc/home_chat_event.dart';
import 'package:secret/features/home/presentation/bloc/home_chat_state.dart';

class HomeChatBloc extends Bloc<HomeChatEvent, HomeChatState> {
  final HomeChatRepository repository;
  HomeChatBloc(this.repository) : super(HomeChatInitial()) {
    on<GetHomeChatList>((event, emit) async {
      emit(HomeChatsLoading());

      await emit.forEach(
        repository.getChatList(),
        onData: (chats) {
          return HomeChatsLoaded(chats: chats);
        },
        onError: (error, stackTrace) {
          return HomeChatFailure(message: error.toString());
        },
      );
    });
  }
}

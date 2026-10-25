import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:secret/features/home/domain/repositories/home_chat_repository.dart';
import 'package:secret/features/home/presentation/bloc/home_chat_bloc.dart';
import 'package:secret/features/home/presentation/bloc/home_chat_event.dart';
import 'package:secret/features/home/presentation/bloc/home_chat_state.dart';
import 'package:secret/features/home/presentation/widgets/home_chat_item.dart';
import 'package:secret/features/home/service/chat_selection_service.dart';

class HomeChatList extends StatefulWidget {
  const HomeChatList({super.key});

  @override
  State<HomeChatList> createState() => _HomeChatListState();
}

class _HomeChatListState extends State<HomeChatList> {
  final myId = FirebaseAuth.instance.currentUser?.uid;

  final selectionService = GetIt.I<ChatSelectionService>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeChatBloc(GetIt.I<HomeChatRepository>())..add(GetHomeChatList()),
      child: BlocBuilder<HomeChatBloc, HomeChatState>(
        builder: (context, chatState) {
          if (chatState is HomeChatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatState is HomeChatFailure) {
            return Center(child: Text(chatState.message));
          }
          if (chatState is! HomeChatsLoaded) {
            return const SizedBox.shrink();
          }

          final chats = chatState.chats;

          if (chats.isEmpty) {
            return const Center(child: Text('No chats yet', style: TextStyle(fontWeight: .w600),));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return HomeChatItem(
                myId: myId,
                chat: chat,
                selectionService: selectionService,
              );
            },
          );
        },
      ),
    );
  }
}

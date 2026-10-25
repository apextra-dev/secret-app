import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:secret/features/chat/domain/repositories/chat_repository.dart';
import 'package:secret/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:secret/features/chat/presentation/bloc/chat_event.dart';
import 'package:secret/features/chat/presentation/bloc/chat_state.dart';
import 'package:secret/features/home/domain/entities/home_chat_entity.dart';
import 'package:secret/features/home/service/chat_selection_service.dart'
    show ChatSelectionService;

class HomeChatItem extends StatelessWidget {
  final HomeChatEntity chat;
  final ChatSelectionService selectionService;
  final myId;

  const HomeChatItem({
    super.key,
    required this.myId,
    required this.chat,
    required this.selectionService,
  });

  String formatLastMessageTime(int? timestamp) {
    if (timestamp == null) return '';
    final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (messageDate.year == now.year &&
        messageDate.month == now.month &&
        messageDate.day == now.day) {
      return DateFormat('HH:mm').format(messageDate);
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (messageDate.year == yesterday.year &&
        messageDate.month == yesterday.month &&
        messageDate.day == yesterday.day) {
      return 'yesterday';
    }
    if (messageDate.year != now.year) {
      return DateFormat('dd.MM.yy').format(messageDate);
    }
    return DateFormat('dd.MM').format(messageDate);
  }

  @override
  Widget build(BuildContext context) {
    final partnerId = chat.partnerId;
    final partnerName = chat.partnerName;
    final lastMessage = chat.lastMessage;
    final lastMessageSenderId = chat.lastMessageSenderId;
    final timestamp = chat.timestamp as int? ?? 0;
    final chatRoomId = chat.chatRoomId;

    final myId = FirebaseAuth.instance.currentUser?.uid;
    final isSelected = selectionService.selectedPartnerIds.contains(partnerId);
    final isMyMessage = lastMessageSenderId == myId;

    return BlocProvider(
      create: (context) =>
          ChatBloc(GetIt.I<ChatRepository>())
            ..add(GetPartnerStatus(partnerId: partnerId, myId: myId ?? '')),
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, statusState) {
          bool isOnline = false;
          bool isTyping = false;
          int unreadCount = 0;

          if (statusState is ReturnUserStatus) {
            isOnline = statusState.presence.isOnline;
            isTyping = statusState.presence.isTyping;
            unreadCount = statusState.presence.unreadCount;
          }

          return ListTile(
            leading: Stack(
              children: [
                isSelected
                    ? const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.done, color: Colors.white),
                      )
                    : CircleAvatar(
                        radius: 25,
                        child: Text(
                          partnerName.isNotEmpty ? partnerName[0] : '?',
                        ),
                      ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(partnerName),
            subtitle: Text(
              isTyping
                  ? 'typing...'
                  : isMyMessage
                  ? 'You: $lastMessage'
                  : '$partnerName: $lastMessage',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatLastMessageTime(timestamp)),
                const SizedBox(height: 4),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 22),
              ],
            ),
            onLongPress: () {
              selectionService.toggleSelection(partnerId);
            },
            onTap: () {
              if (selectionService.isSelectionMode) {
                selectionService.toggleSelection(partnerId);
              } else {
                context.push('/chat/$chatRoomId/$partnerName/$partnerId');
              }
            },
          );
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:secret/features/home/service/chat_selection_service.dart';

class HomeChatList extends StatefulWidget {
  const HomeChatList({super.key});

  @override
  State<HomeChatList> createState() => _HomeChatListState();
}

class _HomeChatListState extends State<HomeChatList> {
  final _userChatsRef =
      FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL:
                'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
          )
          .ref('user_chats/${FirebaseAuth.instance.currentUser?.uid}')
          .orderByChild('timestamp');

  final selectionService = GetIt.I<ChatSelectionService>();

  @override
  void initState() {
    super.initState();
    _userChatsRef.keepSynced(true);
  }

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

    return DateFormat('dd.MM.yy').format(messageDate);
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      query: _userChatsRef,
      reverse: false,
      shrinkWrap: true,
      sort: (DataSnapshot a, DataSnapshot b) {
        if (a.value is! Map || b.value is! Map) return 0;
        final aMap = Map<String, dynamic>.from(a.value as Map);
        final bMap = Map<String, dynamic>.from(b.value as Map);

        final aTimestamp = aMap['timestamp'] as int? ?? 0;
        final bTimestamp = bMap['timestamp'] as int? ?? 0;

        return bTimestamp.compareTo(aTimestamp);
      },
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, snapshot, animation, index) {
        final chat = Map<String, dynamic>.from(snapshot.value as Map);

        final partnerId = chat['partnerId'] ?? '';
        final partnerName = chat['partnerName'] ?? 'User';

        final lastMessage = chat['lastMessage'] ?? '';
        final lastMessageSenderId = chat['lastMessageSenderId'] ?? '';
        final timestamp = chat['timestamp'] ?? '';

        final chatRoomId = chat['chatRoomId'] ?? '';

        final unreadCount = chat['unreadCount'] ?? 0;

        final isSelected = selectionService.selectedPartnerIds.contains(
          partnerId,
        );

        bool isMyMessage;

        if (lastMessageSenderId == FirebaseAuth.instance.currentUser?.uid) {
          isMyMessage = true;
        } else {
          isMyMessage = false;
        }

        return SizeTransition(
          sizeFactor: animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: ListTile(
              leading: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instanceFor(
                  app: Firebase.app(),
                  databaseURL:
                      'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
                ).ref('users/$partnerId/status').onValue,
                builder: (context, statusSnapshot) {
                  bool isOnline = false;

                  if (statusSnapshot.hasData &&
                      statusSnapshot.data?.snapshot.value != null) {
                    final statusData = Map<String, dynamic>.from(
                      statusSnapshot.data!.snapshot.value as Map,
                    );
                    isOnline = statusData['state'] == 'online';
                  }
                  return Stack(
                    children: [
                      isSelected
                          ? CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.done, color: Colors.white),
                            )
                          : CircleAvatar(
                              radius: 25,
                              child: Text(partnerName[0]),
                            ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border(
                                top: BorderSide(color: Colors.white, width: 2),
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                left: BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              title: Text(partnerName),
              subtitle: Text(
                (chat['isTyping'] == true)
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
            ),
          ),
        );
      },
    );
  }
}

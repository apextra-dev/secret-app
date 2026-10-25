import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key, this.chatRoomId});

  final chatRoomId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController _scrollController = ScrollController();
  late final DatabaseReference _ref;

  @override
  void initState() {
    super.initState();

    _ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref('chats/${widget.chatRoomId}');

    _ref.keepSynced(true);
  }

  String formatLastMessageTime(int? timestamp) {
    if (timestamp == null) return '';

    final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(messageDate);
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      controller: _scrollController,
      sort: (DataSnapshot a, DataSnapshot b) {
        if (a.value is! Map || b.value is! Map) {
          return 0;
        }

        final aMap = Map<String, dynamic>.from(a.value as Map);
        final bMap = Map<String, dynamic>.from(b.value as Map);

        final aTimestamp = aMap['timestamp'] as int? ?? 0;
        final bTimestamp = bMap['timestamp'] as int? ?? 0;

        return bTimestamp.compareTo(aTimestamp);
      },
      query: _ref.orderByChild('timestamp'),
      reverse: true,
      padding: const EdgeInsets.only(top: 10),
      itemBuilder: (context, snapshot, animation, index) {
        if (snapshot.value == null || snapshot.value is! Map) {
          return const SizedBox.shrink();
        }

        final message = Map<String, dynamic>.from(snapshot.value as Map);
        final text = message['text'] ?? '';
        final isMe =
            message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
        final bool isRead = message['isRead'] as bool? ?? false;
        final timestamp = message['timestamp'] ?? 0;

        if (snapshot.key != null &&
            snapshot.key!.startsWith('-') &&
            !isMe &&
            !isRead) {
          _ref.child(snapshot.key!).child('isRead').set(true);
        }

        return SizeTransition(
          sizeFactor: animation,
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2D2D2D)
                          : Colors.black)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black),
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatLastMessageTime(timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? Colors.white70
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white60
                                    : Colors.black54),
                        ),
                      ),

                      if (isMe) ...[
                        const SizedBox(width: 4),
                        StreamBuilder<DatabaseEvent>(
                          stream: _ref
                              .child(snapshot.key!)
                              .child('isRead')
                              .onValue,
                          builder: (context, isReadSnapshot) {
                            bool liveIsRead = isRead;

                            if (isReadSnapshot.hasData &&
                                isReadSnapshot.data?.snapshot.value != null) {
                              liveIsRead =
                                  isReadSnapshot.data!.snapshot.value as bool;
                            }

                            return Icon(
                              liveIsRead ? Icons.done_all : Icons.done,
                              color: Colors.white,
                              size: 15,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

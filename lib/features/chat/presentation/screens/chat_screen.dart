import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:secret/features/chat/domain/repositories/chat_repository.dart';
import 'package:secret/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:secret/features/chat/presentation/bloc/chat_event.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String partnerName;
  final String partnerId;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.partnerName,
    required this.partnerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final DatabaseReference _ref;
  late final DatabaseReference _refMyChat;
  late final DatabaseReference _refSecondChat;

  final TextEditingController _sendController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  StreamSubscription<DatabaseEvent>? _typingSubscription;
  bool _isMeTyping = false;
  bool _isPartnerTyping = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref('chats/${widget.chatRoomId}');

    _ref.keepSynced(true);

    _refMyChat = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref('user_chats/${FirebaseAuth.instance.currentUser?.uid}/${widget.partnerId}');

    _refSecondChat = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref('user_chats/${widget.partnerId}/${FirebaseAuth.instance.currentUser?.uid}');

    _refMyChat.update({'unreadCount': 0});

    _sendController.addListener(() {
      setState(() {});
    });

    _typingSubscription = _refMyChat.child('isTyping').onValue.listen((event) {
      if (mounted) {
        setState(() {
          _isPartnerTyping = event.snapshot.value as bool? ?? false;
        });
      }
    });
  }

  void _onTyping(String text) {
    _debounce?.cancel();

    if (text.trim().isEmpty) {
      _updateTypingStatus(false);
      return;
    }

    if (!_isMeTyping) {
      _updateTypingStatus(true);
    }

    _debounce = Timer(const Duration(seconds: 2), () {
      _updateTypingStatus(false);
    });
  }

  void _updateTypingStatus(bool typing) {
    _isMeTyping = typing;
    _refSecondChat.update({'isTyping': typing});
  }

  String formatLastMessageTime(int? timestamp) {
    if (timestamp == null) return '';

    final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(messageDate);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _typingSubscription?.cancel();
    _refSecondChat.update({'isTyping': false});

    _refMyChat.update({'unreadCount': 0});

    _sendController.removeListener(() {});
    _scrollController.dispose();
    _sendController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(widget.partnerId)
              .child('status')
              .onValue,
          builder: (context, snapshot) {
            bool isOnline = false;

            if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
              final data = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );
              isOnline = data['state'] == 'online';
            }

            return Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      child: Text(
                        widget.partnerName[0],
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 2),
                              bottom: BorderSide(color: Colors.white, width: 1),
                              left: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.partnerName),
                    Text(
                      _isPartnerTyping
                          ? 'typing...'
                          : isOnline
                          ? 'online'
                          : 'last seen recently',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: BlocProvider(
        create: (_) => ChatBloc(GetIt.I<ChatRepository>()),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: FirebaseAnimatedList(
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

                    final message = Map<String, dynamic>.from(
                      snapshot.value as Map,
                    );
                    final text = message['text'] ?? '';
                    final isMe =
                        message['senderId'] ==
                        FirebaseAuth.instance.currentUser?.uid;
                    final bool isRead = message['isRead'] as bool? ?? false;
                    final timestamp = message['timestamp'] ?? '';

                    if (snapshot.key != null &&
                        snapshot.key!.startsWith('-') &&
                        !isMe &&
                        !isRead) {
                      _ref.child(snapshot.key!).child('isRead').set(true);
                    }

                    return SizeTransition(
                      sizeFactor: animation,
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF000000)
                                : const Color(0xFFE0E0E0),
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
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Вывод времени
                                  Text(
                                    formatLastMessageTime(timestamp),
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
                                            isReadSnapshot
                                                    .data
                                                    ?.snapshot
                                                    .value !=
                                                null) {
                                          liveIsRead =
                                              isReadSnapshot
                                                      .data!
                                                      .snapshot
                                                      .value
                                                  as bool;
                                        }

                                        return Icon(
                                          liveIsRead
                                              ? Icons.done_all
                                              : Icons.done,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: _onTyping,
                        focusNode: _focusNode,
                        controller: _sendController,
                        decoration: InputDecoration(
                          hintText: 'Enter message...',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (newContext) {
                        final bool isCanSend = _sendController.text
                            .trim()
                            .isNotEmpty;
                        return IconButton(
                          onPressed: isCanSend
                              ? () {
                                  final myUid =
                                      FirebaseAuth.instance.currentUser?.uid
                                          as String;
                                  final myName =
                                      FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.displayName ??
                                      'User';
                                  final text = _sendController.text.trim();

                                  _refMyChat.update({
                                    'chatRoomId': widget.chatRoomId,
                                    'partnerId': widget.partnerId,
                                    'partnerName': widget.partnerName,
                                    'lastMessage': text,
                                    'lastMessageSenderId': myUid,
                                    'timestamp': ServerValue.timestamp,
                                  });

                                  _refSecondChat.update({
                                    'chatRoomId': widget.chatRoomId,
                                    'partnerId': myUid,
                                    'partnerName': myName,
                                    'lastMessage': text,
                                    'lastMessageSenderId': myUid,
                                    'timestamp': ServerValue.timestamp,
                                    'unreadCount': ServerValue.increment(1),
                                  });

                                  newContext.read<ChatBloc>().add(
                                    SendMessage(
                                      chatRoomId: widget.chatRoomId,
                                      senderId: myUid,
                                      text: text,
                                    ),
                                  );
                                  _sendController.clear();
                                }
                              : null,
                          icon: Icon(
                            Icons.send,
                            color: isCanSend
                                ? Colors.black
                                : const Color(0xFFC3C3C3),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:secret/features/chat/domain/repositories/chat_repository.dart';
import 'package:secret/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:secret/features/chat/presentation/bloc/chat_event.dart';
import 'package:secret/features/chat/presentation/bloc/chat_state.dart';
import 'package:secret/features/chat/presentation/widgets/chat_list.dart';

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
  final TextEditingController _sendController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();

    final myId = FirebaseAuth.instance.currentUser?.uid ?? '';

    _chatBloc = ChatBloc(GetIt.I<ChatRepository>())
      ..add(GetPartnerStatus(partnerId: widget.partnerId, myId: myId))
      ..add(ResetCounter(partnerId: widget.partnerId, myId: myId));
  }

  @override
  void dispose() {
    _sendController.removeListener(() {});
    _sendController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final myId = FirebaseAuth.instance.currentUser?.uid as String;

    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ReturnUserStatus) {
                final isOnline = state.presence.isOnline;
                final isTyping = state.presence.isTyping;

                return GestureDetector(
                  onTap: () {
                    context.push(
                      '/partner_profile/${widget.partnerId}/${widget.partnerName}',
                    );
                  },
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            child: Text(widget.partnerName[0]),
                          ),
                          if (isOnline)
                            Positioned(
                              right: 1,
                              bottom: 1,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                  ),
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
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
                            isTyping
                                ? 'typing...'
                                : isOnline
                                ? 'online'
                                : 'last seen recently',
                            style: isOnline
                                ? TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: .w400,
                                  )
                                : Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return Text(
                'connecting...',
                style: Theme.of(context).textTheme.bodyMedium,
              );
            },
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isDark
                  ? AssetImage('assets/images/chat/dark_bg.jpeg')
                  : AssetImage('assets/images/chat/light_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(child: ChatList(chatRoomId: widget.chatRoomId)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 15, 12, 0),
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2C2C2E).withOpacity(0.8)
                          : const Color(0xFFF2F2F7).withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.black.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (textFieldContext) {
                            return Expanded(
                              child: TextField(
                                onChanged: (text) {
                                  textFieldContext.read<ChatBloc>().add(
                                    OnTypingChanged(
                                      myId: myId,
                                      partnerId: widget.partnerId,
                                      text: text,
                                    ),
                                  );
                                },
                                focusNode: _focusNode,
                                controller: _sendController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.attach_file),
                                  hintText: 'Message',
                                  fillColor: Theme.of(context).cardColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                            bool isCanSend = false;

                            if (state is ReturnUserStatus) {
                              isCanSend = state.isTextNotEmpty;
                            }

                            return IconButton(
                              onPressed: isCanSend
                                  ? () {
                                      final text = _sendController.text.trim();

                                      context.read<ChatBloc>().add(
                                        SendMessage(
                                          chatRoomId: widget.chatRoomId,
                                          partnerId: widget.partnerId,
                                          partnerName: widget.partnerName,
                                          senderId: myId,
                                          text: text,
                                        ),
                                      );
                                      isCanSend = false;
                                      _sendController.clear();
                                      context.read<ChatBloc>().add(
                                        OnTypingChanged(
                                          myId: myId,
                                          partnerId: widget.partnerId,
                                          text: '',
                                        ),
                                      );
                                    }
                                  : null,
                              icon: Icon(
                                Icons.send,
                                color: isCanSend
                                    ? const Color(0xFFC3C3C3)
                                    : const Color(0x47C3C3C3),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

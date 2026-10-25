import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret/features/chat/domain/repositories/chat_repository.dart';
import 'package:secret/features/chat/presentation/bloc/chat_event.dart';
import 'package:secret/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc(this.repository) : super(ChatInitial()) {
    StreamSubscription? _presenceSubscription;
    Timer? _debounce;

    on<SendMessage>((event, emit) async {
      try {
        await repository.sendMessage(
          event.chatRoomId,
          event.partnerId,
          event.partnerName,
          event.senderId,
          event.text,
        );
      } catch (e) {
        emit(ChatFailure(message: e.toString()));
      }
    });

    on<GetPartnerStatus>((event, emit) async {
      await _presenceSubscription?.cancel();

      _presenceSubscription = repository
          .getUserState(event.partnerId, event.myId)
          .listen((presence) {
            add(UpdatePartnerStatus(presence));
          });
    });

    on<OnTypingChanged>((event, emit) async {
      _debounce?.cancel();

      final bool hasText = event.text.trim().isNotEmpty;

      if (state is ReturnUserStatus) {
        final currentState = state as ReturnUserStatus;
        emit(
          ReturnUserStatus(
            presence: currentState.presence,
            isTextNotEmpty: hasText,
          ),
        );
      }

      if (!hasText) {
        await repository.updateTypingStatus(event.myId, event.partnerId, false);
        return;
      }

      await repository.updateTypingStatus(event.myId, event.partnerId, true);

      _debounce = Timer(Duration(seconds: 2), () async {
        await repository.updateTypingStatus(event.myId, event.partnerId, false);
      });
    });

    on<ResetCounter>((event, emit) async {
      await repository.resetCounter(event.partnerId, event.myId);
    });

    on<UpdatePartnerStatus>((event, emit) {
      bool currentTextFieldStatus = false;

      if (state is ReturnUserStatus) {
        currentTextFieldStatus = (state as ReturnUserStatus).isTextNotEmpty;
      }

      emit(
        ReturnUserStatus(
          presence: event.presence,
          isTextNotEmpty: currentTextFieldStatus,
        ),
      );
    });
    @override
    Future<void> close() {
      _presenceSubscription?.cancel();
      _debounce?.cancel();
      return super.close();
    }
  }
}

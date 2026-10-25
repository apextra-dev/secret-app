import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:secret/features/presence/data/entities/partner_presence_entity.dart';

class ChatDataSource {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
  );
  final _auth = FirebaseAuth.instance;

  Future<void> sendMessage(
    String chatRoomId,
    String partnerId,
    String partnerName,
    String senderId,
    String text,
  ) async {
    try {
      await _db.ref('chats/$chatRoomId').push().set({
        'senderId': senderId,
        'text': text,
        'isRead': false,
        'timestamp': ServerValue.timestamp,
      });

      _db.ref('user_chats/$senderId/$partnerId').update({
        'chatRoomId': chatRoomId,
        'partnerId': partnerId,
        'partnerName': partnerName,
        'lastMessage': text,
        'lastMessageSenderId': senderId,
        'timestamp': ServerValue.timestamp,
      });

      _db.ref('user_chats/$partnerId/$senderId').update({
        'chatRoomId': chatRoomId,
        'partnerId': senderId,
        'partnerName': _auth.currentUser?.displayName,
        'lastMessage': text,
        'lastMessageSenderId': senderId,
        'timestamp': ServerValue.timestamp,
        'unreadCount': ServerValue.increment(1),
      });
    } catch (e) {
      throw '$e';
    }
  }

  Future<void> updateTypingStatus(
    String myId,
    String partnerId,
    bool isTyping,
  ) async {
    try {
      await _db.ref('user_chats/$partnerId/$myId').update({
        'isTyping': isTyping,
      });
    } catch (e) {
      throw '$e';
    }
  }

  Future<void> resetCounter(String partnerId, String myId) async {
    _db.ref('user_chats/$myId/$partnerId').update({'unreadCount': 0});
  }

  Stream<PartnerPresenceEntitiy> getUserStatus(String partnerId, String myId) {
    final onlineStatus = _db.ref('users/$partnerId/status').onValue.map((
      event,
    ) {
      final data = event.snapshot.value as Map? ?? {};
      return data['state'] == 'online';
    });

    final typingStatus = _db
        .ref('user_chats/$myId/$partnerId/isTyping')
        .onValue
        .map((event) {
          return event.snapshot.value as bool? ?? false;
        });

    final unreadCount = _db
        .ref('user_chats/$myId/$partnerId/unreadCount')
        .onValue
        .map((event) {
          return event.snapshot.value as int? ?? 0;
        });

    return Rx.combineLatest3<bool, bool, int, PartnerPresenceEntitiy>(
      onlineStatus,
      typingStatus,
      unreadCount,
      (isOnline, isTyping, unreadCount) => PartnerPresenceEntitiy(
        isOnline: isOnline,
        isTyping: isTyping,
        unreadCount: unreadCount,
      ),
    );
  }
}

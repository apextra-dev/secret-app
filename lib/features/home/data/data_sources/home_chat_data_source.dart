import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:secret/features/home/data/models/home_chat_model.dart';
import 'package:secret/features/home/domain/entities/home_chat_entity.dart';

class HomeChatDataSource {
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
  );
  final _auth = FirebaseAuth.instance;

  Stream<List<HomeChatEntity>> getChatsStream() {
    final uid = _auth.currentUser?.uid;
    return _db.ref('user_chats/$uid').orderByChild('timestamp').onValue.map((
      event,
    ) {
      final rawData = event.snapshot.value as Map<Object?, Object?>? ?? {};

      _db.ref('user_chats/$uid').orderByChild('timestamp').keepSynced(true);

      return rawData.entries.map((e) {
        final valueMap = e.value as Map<Object?, Object?>? ?? {};
        final formattedMap = Map<String, dynamic>.from(valueMap);

        return HomeChatModel.fromMap(formattedMap);
      }).toList();
    });
  }
}

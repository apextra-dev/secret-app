import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:secret/core/network/user_state_network.dart';
import 'package:secret/features/auth/data/models/username_model.dart';

class AuthDataSource {
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
  );
  final _auth = FirebaseAuth.instance;

  Future<void> createUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);

      final uid = userCredential.user?.uid;

      await _db.ref('users/$uid').set({'name': name, 'email': email});
    } catch (e) {
      throw '$e';
    }
  }

  Future<void> signOut() async {
    try {
      GetIt.I<UserStateNetwork>().stopTracking();
      await _auth.signOut();
    } catch (e) {
      throw '$e';
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw '$e';
    }
  }

  Future<UsernameModel> checkUniqueness(String username) async {
    try {
      final snapshot = await _db.ref('usernames/$username').get();

      if (snapshot.value != null) {
        return UsernameModel(username: username, isUnique: false);
      }

      return UsernameModel(username: username, isUnique: true);
    } catch (e) {
      throw '$e';
    }
  }

    Future<void> changeUserInfo(
    String name,
    String oldUsername,
    String newUsername,
  ) async {
    try {
      final myId = _auth.currentUser?.uid;

      await _auth.currentUser?.updateDisplayName(name);

      await _db.ref('usernames/$oldUsername').remove();
      await _db.ref('users/$myId').update({'username': newUsername});
      await _db.ref('usernames').push().set({newUsername.toLowerCase(): myId});
    } catch (e) {
      throw '$e';
    }
  }
}

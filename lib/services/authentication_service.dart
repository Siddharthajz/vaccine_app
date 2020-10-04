import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/models/Child.dart';
import 'package:vaccineApp/models/Parent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vaccineApp/services/firestore_service.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = locator<FirestoreService>();

  Parent _currentUser;
  Parent get currentUser => _currentUser;

  Child _activeChild;
  Child get activeChild => _activeChild;

  Future loginWithEmail({
    @required String email,
    @required String password,
  }) async {
    try {
      var authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _populateCurrentUser(authResult.user);
      return authResult.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future signUpWithEmail({
    @required String email,
    @required String password,
    @required String fname,
    @required String surname,
    @required String dob,
    @required String selectedChild,
  }) async {
    try {
      var authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // create a new user profile on firestore
      _currentUser = Parent(
        uid: authResult.user.uid,
        email: email,
        fname: fname,
        surname: surname,
        dob: dob,
        selectedChild: selectedChild,
      );

      await _firestoreService.createUser(_currentUser);

      return authResult.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future<bool> isUserLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    await _populateCurrentUser(user);
    await _setActiveChild(user);
    return user != null;
  }

  Future _populateCurrentUser(User user) async {
    if (user != null) {
      _currentUser = await _firestoreService.getUser(user.uid);
    }
  }

  Future _setActiveChild(User user) async {
    if (user != null) {
      _activeChild = await _firestoreService.getActiveChild(user.uid);
    }
  }

  Future logOut() async {
    await _firebaseAuth.signOut();
  }
}

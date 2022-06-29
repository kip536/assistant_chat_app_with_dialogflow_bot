
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebaseUser(User user) {
    return user != null
        ? UserModel(
            email: 'email',
            name: 'name',
            image: 'image',
            date: DateTime.now(),
            uid: user.uid)
        : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = result.user;
      Constants.myUserId = firebaseUser!.uid;
      HelperFunctions.saveUserIdSharedPreference(Constants.myUserId!);
      return _userFromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e){
      print(e.message);
    }
    catch (e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(
      String username, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = result.user;
      Constants.myUserId = firebaseUser!.uid;
      HelperFunctions.saveUserIdSharedPreference(Constants.myUserId!);
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }
}

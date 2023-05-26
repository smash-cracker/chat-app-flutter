import 'package:chat/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<UserModel?> getUserCurrentData() async {
    print(auth.currentUser?.phoneNumber);
    var userData = await firestore
        .collection('users')
        .doc(auth.currentUser?.phoneNumber)
        .get();
    UserModel? userModel;
    if (userData.data() != null) {
      userModel = UserModel.fromMap(userData.data()!);
    }
    return userModel;
  }

  Stream<UserModel> userData(String userID) {
    return firestore.collection('users').doc(userID).snapshots().map(
          (event) => UserModel.fromMap(event.data()!),
        );
  }

  void setUserState(bool isOnline) async {
    firestore.collection('users').doc(auth.currentUser!.phoneNumber).update({
      'isOnline': isOnline,
    });
  }
}

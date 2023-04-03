
import 'dart:developer';

import 'package:chatt_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs{
  /// for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  /// to create firebase coludstore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //to return current user
  static User get user => auth.currentUser!;
  // for storing self information
  static late ChatUser me;


  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .get())
        .exists;
  }
  // for getting current user info
  static Future<void> getSelfInfo() async {
        await firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .then((user) async {
              if(user.exists){
                me = ChatUser.fromJson(user.data()!);
                log('My Data: ${user.data()}');
              }else{
                await creatUser().then((value) => getSelfInfo());
              }
        });
     //await firestore.collection('users').doc(user.uid).get().then((user) async {
      // if (user.exists) {
      //   me = ChatUser.fromJson(user.data()!);
      //   await getFirebaseMessagingToken();
      //
      //   //for setting user status to active
      //   APIs.updateActiveStatus(true);
      //   log('My Data: ${user.data()}');
      // } else {
      //   await createUser().then((value) => getSelfInfo());
      // }
    //});
  }

  // for creating a new user
  static Future<void> creatUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        createdId: time,
        about: "Hey , I am using Chat!",
        name: user.displayName.toString(),
        lastActive: time,
        id: user.uid,
        isOnline: false,
        pushToken: "",
        email: user.email.toString());
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }
  // for getting all users firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
    return firestore.collection('users').where('id', isNotEqualTo: user.uid).snapshots();
  }

  // update profile picture of user
  //   static Future<void> updateProfilePicture(File file) async {
  //     //getting image file extension
  //     final ext = file.path.split('.').last;
  //     log('Extension: $ext');
  //
  //     //storage file ref with path
  //     final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
  //
  //     //uploading image
  //     await ref
  //         .putFile(file, SettableMetadata(contentType: 'image/$ext'))
  //         .then((p0) {
  //       log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  //     });


 }


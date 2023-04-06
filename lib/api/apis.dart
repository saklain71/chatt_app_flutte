
import 'dart:developer';
import 'dart:io';

import 'package:chatt_app/models/chat_user.dart';
import 'package:chatt_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs{
  /// for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  /// to create firebase coludstore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// to create firebase coludstore
  static FirebaseStorage storage = FirebaseStorage.instance;

  ///to return current user
  static User get user => auth.currentUser!;
  /// for storing self information
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
    static Future<void> updateProfilePicture(File file) async {
      //     //getting image file extension
      final ext = file.path
          .split('.')
          .last;
      log('Extension: $ext');
      //storage file ref with path
      final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
      //uploading image
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });
      // uploading image in firestore database
      me.image = await ref.getDownloadURL();
      await firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'name': me.image,
      });
    }

    ///****************** Chat Scree Related APIS *************


  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages from firebase database firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }
  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async{
    // message sending time also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    // message to send
    final Message message = Message(toId: chatUser.id, msg: msg, read: '', type: Type.text, fromId: user.uid, sent: time);
    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
   }
  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

   // get only last message for specific call
 static Stream<QuerySnapshot<Map<String,dynamic>>> getLastMessage(ChatUser user){
    return  firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1)
        .snapshots();
 }

}


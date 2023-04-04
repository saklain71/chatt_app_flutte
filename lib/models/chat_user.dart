import 'dart:convert';

ChatUser chatUserFromJson(String str) => ChatUser.fromJson(json.decode(str));

String chatUserToJson(ChatUser data) => json.encode(data.toJson());

class ChatUser {
  ChatUser({
    required this.image,
    required this.createdId,
    required this.about,
    required this.name,
    required this.lastActive,
    required this.id,
    required this.isOnline,
    required this.pushToken,
    required this.email,
  });

  late String image;
  late String createdId;
  late String about;
  late String name;
  late String lastActive;
  late String id;
  late bool isOnline;
  late String pushToken;
  late String email;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    image: json["image"] ?? [],
    createdId: json["created_id"]?? [],
    about: json["about"]?? [],
    name: json["name"]?? [],
    lastActive: json["last_active"]?? [],
    id: json["id"]?? [],
    isOnline: json["is_online"]?? [],
    pushToken: json["push_token"]?? [],
    email: json["email"]?? [],
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["image"]= image;
  data["created_id"]= createdId;
  data["about"]= about;
  data["name"]= name;
  data["last_active"]= lastActive;
  data["id"]= id;
  data["is_online"]= isOnline;
  data["push_token"]= pushToken;
  data["email"]= email;
  return data;
  }
}
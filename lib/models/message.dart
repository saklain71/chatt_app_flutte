import 'dart:convert';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromId,
    required this.sent,
  });

  String toId;
  String msg;
  String read;
  String fromId;
  String sent;
  Type type;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    toId: json["toId"].toString(),
    msg: json["msg"].toString(),
    type: json["type"].toString() == Type.image.name ? Type.image : Type.text ,
    read: json["read"].toString(),
    fromId: json["fromId"].toString(),
    sent: json["sent"].toString(),

  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

   enum Type{ text, image}
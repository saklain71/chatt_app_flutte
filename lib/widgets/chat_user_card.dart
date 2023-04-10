
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/helper/my_date_util.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/models/chat_user.dart';
import 'package:chatt_app/models/message.dart';
import 'package:chatt_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import 'dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {

  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last mesage info if null --> no message
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.005),
      //color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context,  snapshot) {
            final data = snapshot.data?.docs;
            final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty) {
              _message = list[0];
            }
            return ListTile(
              // leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_)=>  ProfileDialog(user: widget.user,));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.3),
                  child: CachedNetworkImage(
                    height: mq.height * 0.055,
                    width: mq.height * 0.055,
                    //color: Colors.blue,
                    imageUrl: widget.user.image,
                    //placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.error)),
                  ),
                ),
              ),

              title: Text(widget.user.name),
              subtitle: Text(
                  _message != null ?
                      _message!.type == Type.image ?
                          "📸"
                          : _message!.msg
                          : widget.user.about,
                maxLines: 1,

              ),
              // trailing: Text("${DateTime.now().hour}:${DateTime.now().minute}",
              // style: TextStyle(color: Colors.black54),),

              //last message time
              trailing: _message == null
                  ? null : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                  ? Container(
                width: mq.height * 0.02,
                height: mq.height * 0.02,
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    borderRadius: BorderRadius.circular(mq.height * 0.01)
                ),
              ) : Text(
                MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                style: const TextStyle(color: Colors.black54),
              ),
            );
          },),
      ),
    );
  }
}

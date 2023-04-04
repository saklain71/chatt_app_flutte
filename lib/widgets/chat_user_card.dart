
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/models/chat_user.dart';
import 'package:chatt_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {

  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
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
        child: ListTile(
          // leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
           leading: ClipRRect(
             borderRadius: BorderRadius.circular(mq.height * 0.3),
             child: CachedNetworkImage(
               height: mq.height * 0.055,
               width: mq.height * 0.055,
               //color: Colors.blue,
               imageUrl: widget.user.image,
               //placeholder: (context, url) => const CircularProgressIndicator(),
               errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.error)),
             ),
           ),

          title: Text(widget.user.name),
          subtitle: Text(widget.user.about),
          // trailing: Text("${DateTime.now().hour}:${DateTime.now().minute}",
          // style: TextStyle(color: Colors.black54),),
          trailing: Container(
            width: mq.height * 0.02,
            height: mq.height * 0.02,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade400,
              borderRadius: BorderRadius.circular(mq.height * 0.01)
            ),
          ),
        ),
      ),
    );
  }
}

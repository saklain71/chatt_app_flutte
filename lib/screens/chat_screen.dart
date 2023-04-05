import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/models/chat_user.dart';
import 'package:chatt_app/models/message.dart';
import 'package:chatt_app/widgets/message_card.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // to store all message
    List<Message> _list = [];
    // for handing message to text changes
    final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        backgroundColor: Color.fromARGB(255, 2234, 248, 255),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot){
                    // if data is loading
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                         return const SizedBox();
                    // if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                         final data = snapshot.data?.docs;
                        _list =
                            data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                       // log('Data ${jsonEncode(data)}');


                         if(_list.isNotEmpty){
                          return ListView.builder(
                              itemCount: _list.length ,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index){
                             //  return Text("Message: ${_list[index]}");
                                return  MessageCard(message: _list[index],);
                              }
                          );
                        }else{
                          return  const Center(child: Text("Say Hi🤚",
                          style: TextStyle(fontSize: 20),));
                        }
                    }

                  }
              ),
            ),
            // _chatinput widget
            _chatInput(),
          ],
        ),
      ),
    );
  }
  // app bar widget
  Widget _appBar(){
    return  InkWell(
      onTap: (){},
      child: Row(
        children: [
          // back button
          IconButton(onPressed: ()=>Navigator.pop(context),
           icon: Icon(Icons.arrow_back, color: Colors.black54,)),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.2),
            child: CachedNetworkImage(
              height: mq.height * 0.04,
              width: mq.height * 0.04,
              //color: Colors.blue,
              imageUrl: widget.user.image,
              //placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.error)),
            ),
          ),
          SizedBox(
            width: mq.width * 0.03,
          ),

          //user name & last seen time
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user.name,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600
              ),),
              SizedBox(height: 2),
              Text("last seen available",
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                ),)
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput(){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: mq.height * 0.01,horizontal: mq.width * 0.05),
      child: Row(
        children: [
          // input fields and buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // Emoji button
                  IconButton(onPressed: (){

                  }, icon: const Icon(Icons.emoji_emotions, color: Colors.blueAccent,size: 25,)),
                  // Text input
                   Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Type Something...",
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                  )),
                  // pick image from gallery button
                  IconButton(onPressed: (){

                  }, icon: const Icon(Icons.image, color: Colors.blueAccent, size: 26,)),
                  // Pick image from camera
                  IconButton(onPressed: (){

                  }, icon: const Icon(Icons.camera_alt_outlined, color: Colors.blueAccent, size: 26,)),
                ],
              ),
            ),
          ),
          // message send buttons
          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty){
              APIs.sendMessage(widget.user, _textController.text);
              log('messegae sent ${_textController.text} ');
              _textController.text = "";
            }
          },
           shape: const CircleBorder(),
            minWidth: 0,
            padding: const EdgeInsets.only(bottom: 10, right: 5, left: 10, top: 10),
            color: Colors.blueAccent,
            child: const Icon(Icons.send, color: Colors.white, size: 26,),)
        ],
      ),
    );
  }

  // button chat input field
}

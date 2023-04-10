import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/helper/my_date_util.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/models/chat_user.dart';
import 'package:chatt_app/models/message.dart';
import 'package:chatt_app/screens/view_profile_screen.dart';
import 'package:chatt_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    // for storing value of showing or hiding emoji
    // isUploading -- for cheacking id image is uploading or not?
    bool _showEmoji = false , _isUploading = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if(_showEmoji){
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            }
            else{
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 2234, 248, 255),
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
                                  reverse: true,
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
                 // progress indicator for showing uploading
                 if(_isUploading)
                 const Align(
                   alignment: Alignment.centerRight,
                     child: Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                     child: CircularProgressIndicator(strokeWidth: 2,))),

                // _chatinput widget
                _chatInput(),
                // show emoji on keybord emoji button click & vice versa
                if(_showEmoji)
                 SizedBox(
                height: mq.height * 0.35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor:  const Color.fromARGB(255, 2234, 248, 255),
                      columns: 7,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                  ),
                ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
  // app bar widget
  Widget _appBar(){
    return  InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user) ));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              // back button
              IconButton(onPressed: ()=> Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black54,)),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.2),
                child: CachedNetworkImage(
                  height: mq.height * 0.04,
                  width: mq.height * 0.04,
                  //color: Colors.blue,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
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
                  Text(list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600
                    ),),
                  const SizedBox(height: 2),
                  Text(list.isNotEmpty ?
                  list[0].isOnline ? 'Online'
                      : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                      : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive) ,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),)
                ],
              )
            ],
          );
        })
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
                    FocusScope.of(context).unfocus();
                    setState(()=> _showEmoji = !_showEmoji);
                  }, icon: const Icon(Icons.emoji_emotions, color: Colors.blueAccent,size: 25,)),
                  // Text input
                   Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: (){
                      if(_showEmoji) setState(()=> _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                      hintText: "Type Something...",
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                  )),

                  // pick image from gallery button
                  IconButton(onPressed: () async {
                    //take picture from camera button
                    final ImagePicker picker = ImagePicker();
                    // Picking multiple image
                    final List<XFile> images = await picker.pickMultiImage( imageQuality: 80);
                    // uploading and sending image one by one
                    for(var i in images){
                      log('Image Path: ${i.path}');
                      setState(()=> _isUploading = true);
                      // to update image Function
                      await APIs.sendChatImage(widget.user,File(i.path));
                      setState(()=> _isUploading = false);
                    }
                  }, icon: const Icon(Icons.image, color: Colors.blueAccent, size: 26,)),
                  // Pick image from camera
                  IconButton(
                    onPressed: () async {
                    //take picture from camera button
                    final ImagePicker picker = ImagePicker();
                    // Pick an image
                    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      setState(() {

                      });
                      // to update image Function
                      await APIs.sendChatImage(widget.user,File(image.path));
                      // for hiding bottom sheet
                     //   Navigator.pop(context);
                    }
                  }, icon: const Icon(
                    Icons.camera_alt_outlined,
                       color: Colors.blueAccent, size: 26,)),
                   ],
              ),
            ),
          ),
          // message send buttons
          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty){
              APIs.sendMessage(widget.user, _textController.text, Type.text);
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

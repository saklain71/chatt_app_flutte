import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/helper/dialogs.dart';
import 'package:chatt_app/helper/my_date_util.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

// for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({Key? key, required this.message}) : super(key: key);
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: (){
          _showBottomSheet(isMe);
        },
        child: isMe
        ? _greenMessage()
        :_blueMessage());

  }

// sender or another user message
  Widget _blueMessage(){
    // update last read message if sender and reciever are different
    if(widget.message.read.isNotEmpty){
      APIs.updateMessageReadStatus(widget.message);
      log('message read updated');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * 0.02 : mq.width * 0.04),
            decoration:  BoxDecoration(
               color:   const Color.fromARGB(225, 221, 245, 255),
              border: Border.all(color: Colors.blueAccent),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30)
              ),
            ),
            margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            child:  widget.message.type == Type.text ?
            Text(
              widget.message.msg,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87),) :
                // show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                  imageUrl: widget.message.msg,
                  placeholder: (context, url) =>
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon (Icons.image,size: 70,)),
            ),
          ),
        ),
        // Show Time
        Row(
          children: [
             SizedBox(width: mq.width * 0.04,),
            // for double tick
            const Icon(Icons.done_all_rounded, color: Colors.lightBlue,),
            // for some space
            SizedBox(width: mq.width * 0.01,),
            // read time
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),),
            SizedBox(width: mq.width * 0.04,),
          ],
        ),
      ],
    );
  }
// our or user message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Show Time
        Row(
          children: [
            SizedBox(width: mq.width * 0.04,),
            if(widget.message.read.isNotEmpty)
            // for double tick
            const Icon(Icons.done_all_rounded, color: Colors.lightBlue,),
            // for some space
            SizedBox(width: mq.width * 0.01,),
            // read time
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * 0.03 : mq.width * 0.04,),
            decoration:  BoxDecoration(
                color: const Color.fromARGB(225, 218, 255, 276),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30)
                ),
            ),
            margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            child:
                widget.message.type == Type.text ?
                Text(
              widget.message.msg,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87),) :
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    // height: mq.height * 0.4,
                    // width: mq.height * 0.4,
                    //color: Colors.blue,
                    imageUrl: widget.message.msg,
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                    errorWidget: (context, url, error) =>
                      const Icon (Icons.image,size: 70,)),
                  ),
                ),
          ),
      ],
    );
  }

  // bottom sheet for modiying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                  vertical: mq.height * 0.015,
                  horizontal: mq.width * 0.37,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10)
                ),
              ),

              // Copy Option
              widget.message.type == Type.text
                  ? _OptionItem(
                  icon: const Icon(
                    Icons.copy_all_outlined,
                    color: Colors.blue,
                    size: 26,),
                  text: "Copy Text",
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text :widget.message.msg));
                    // for hiding bottom sheet
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context, "Text Copied");

                  })
                  // Save Image
                  : _OptionItem(
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Colors.blue,
                    size: 26,),
                  text: "Save Image",
                  onTap: () async {
                    try{
                      log('image Url: ${widget.message.msg}');
                      await GallerySaver.saveImage(widget.message.msg,
                          albumName: "We Chat")
                          .then((success) {
                        // for hiding bottom sheet
                        Navigator.pop(context);
                        if(success != null && success) {
                          Dialogs.showSnackbar(context, "Image Saved on Gallery");
                        }
                      });
                    }
                    catch(e){
                      log('Error While Saving $e');
                    }
                  }),
              // Separator or devider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 04,
                indent: mq.height * 0.4,
              ),

              // Edit  option
              if(widget.message.type == Type.text && isMe)
              _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 26,),
                  text: "Edit Message",
                  onTap: (){
                    // hide the current bottom sheet
                     Navigator.pop(context);
                    _showMessageUpdateDialog();

                  }),

              // Delete Option
              if(isMe)
              _OptionItem(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.blue,
                    size: 26,),
                  text: "Delete Message",
                  onTap: () async {
                    await APIs.deleteMessage(widget.message).then((value) {

                    });
                  }),
              // Separator or devider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 04,
                indent: mq.height * 0.4,
              ),//

              // Sent Option
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue, size: 26,),
                  text: "Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                  onTap: (){}),

              // Read Option
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.red, size: 26,),
                  text: widget.message.read.isEmpty
                      ? "Read At: Not Seen Yet"
                      : "Read At:  ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
                  onTap: (){}),
            ],
          );
        });
  }
  // dialog for updating message content
 void _showMessageUpdateDialog(){
   String updatedMsg = widget.message.msg;

   showDialog(
       context: context,
       builder: (_) => AlertDialog(
         contentPadding: const EdgeInsets.only(
             left: 24, right: 24, top: 20, bottom: 10),
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(20)),

         //title
         title: const Row(
           children: [
             Icon(
               Icons.message,
               color: Colors.blue,
               size: 28,
             ),
             Text('Update Message')
           ],
         ),

         //content
         content: TextFormField(
           initialValue: updatedMsg,
           maxLines: null,
           onChanged: (value) => updatedMsg = value,
           decoration: InputDecoration(
               border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(15))),
         ),

         //actions
         actions: [
           //cancel button
           MaterialButton(
               onPressed: () {
                 //hide alert dialog
                 Navigator.pop(context);
               },
               child: const Text(
                 'Cancel',
                 style: TextStyle(color: Colors.blue, fontSize: 16),
               )),

           //update button
           MaterialButton(
               onPressed: () {
                 //hide alert dialog
                 Navigator.pop(context);
                 APIs.updateMessage(widget.message, updatedMsg);
               },
               child: const Text(
                 'Update',
                 style: TextStyle(color: Colors.blue, fontSize: 16),
               ))
         ],
       ));
 }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String text;
  final  VoidCallback onTap;
  const _OptionItem({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onTap();
      },child: Padding(
        padding:  EdgeInsets.only(
          left: mq.width * 0.05,
          top: mq.height * 0.015,
          bottom: mq.height * 0.015,
        ),
        child: Row(
        children: [
          icon,
          SizedBox(width: mq.width * 0.04,),
          Text(text,style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            letterSpacing: 0.5
          )),
        ],
    ),
      ),
    );
  }
}


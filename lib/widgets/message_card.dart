import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/helper/my_date_util.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/models/message.dart';
import 'package:flutter/material.dart';

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
    return APIs.user.uid == widget.message.fromId?
        _greenMessage() :_blueMessage();
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
}

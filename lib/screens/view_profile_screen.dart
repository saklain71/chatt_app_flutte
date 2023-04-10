
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/helper/dialogs.dart';
import 'package:chatt_app/helper/my_date_util.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// profile screen -- to show in user info
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ViewProfileScreen> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title:  Text(widget.user.name),
        ),
        floatingActionButton:
           Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Joined On: ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),),
            Text( MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdId, showYear: true),
                style: const TextStyle(
                    color: Colors.black87, fontSize: 15)),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // for adding some space
                SizedBox(width: mq.width, height: mq.height * .03),
                //user profile picture
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) =>
                    const CircleAvatar(
                        child: Icon(CupertinoIcons.person)),
                  ),
                ),
                // for adding some space
                SizedBox(height: mq.height * .03),
                // user email label
                Text(widget.user.email,
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 15)),
                // for adding some space
                SizedBox(height: mq.height * .02),
                // user about
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('About: ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),),
                    Text(widget.user.about,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 15)),
                  ],
                ),
                // for adding some space
                SizedBox(height: mq.height * .05),
              ],
            ),
          ),
        )
      ),
    );
  }
}


import 'dart:convert';
import 'dart:developer';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/models/chat_user.dart';
import 'package:chatt_app/screens/profile_screen.dart';
import 'package:chatt_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 // _list<ChatUser> _list = [];
  
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message $message');
      if(APIs.auth.currentUser != null){
        if(message.toString().contains('resume')) APIs.updateActiveStatus(true);
        if(message.toString().contains('pause')) APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when a tap is detected on screen
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search button is on and back pressed the close the search
        //or else simple close current screen on back button click
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }
          else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
              leading: const Icon(CupertinoIcons.home),
              title: _isSearching ?
                    TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Name, Email ...",),
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                      //when search text change updated saerch list
                      onChanged: (value){
                        // search logic
                        _searchList.clear();
                        for(var i in _list){
                          if(i.name.toLowerCase().contains(value.toLowerCase()) ||
                             i.email.toLowerCase().contains(value.toLowerCase()))  {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : Text("We Chat"),
            actions: [
              /// search user button
              IconButton(onPressed: (){
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon:  Icon(_isSearching? CupertinoIcons.clear_circled_solid: Icons.search)),
              /// search features button
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ProfileScreen(user: APIs.me,)));
              }, icon: const Icon(Icons.more_vert)),
            ],
          ),
          /// floating button to add user
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(onPressed: ()async{
             // await APIs.Api.signOut();
             // await GoogleSignIn().signOut();
            },child: const Icon(Icons.add_comment_rounded),),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
              builder: (context, snapshot){
              // if data is loading
              switch(snapshot.connectionState){
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                  // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                  if(_list.isNotEmpty){
                    return ListView.builder(
                        itemCount: _isSearching ? _searchList.length : _list.length ,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index){
                          return ChatUserCard(user: _isSearching ? _searchList[index]  :  _list[index]);
                        }
                    );
                  }else{
                    return Center(child: Text("There is no Connenctions!"));
                  }
              }

              if(snapshot.hasData){
                final data = snapshot.data?.docs;
                for(var i in data!){
                  log('Data ${jsonEncode(i.data())}');
                  _list.add(i.data()['about']);
                }
              }


              }
          ),
        ),
      ),
    );
  }
}

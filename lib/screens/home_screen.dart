import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
          leading: const Icon(CupertinoIcons.home),
          title: const Text("We Chat"),
        actions: [
          /// search user button
          IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
          /// search features button
          IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      /// floating button to add user
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(onPressed: (){},child: const Icon(Icons.add_comment_rounded),),
      ),
    );
  }
}

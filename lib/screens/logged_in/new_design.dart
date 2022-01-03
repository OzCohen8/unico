import 'package:flutter/material.dart';

class NewDesign extends StatefulWidget {
  const NewDesign({Key? key}) : super(key: key);

  @override
  _NewDesignState createState() => _NewDesignState();
}

class _NewDesignState extends State<NewDesign> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text("New Post"),),
    );
  }
}

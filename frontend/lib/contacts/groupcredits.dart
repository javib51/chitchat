import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupInitScreen extends StatefulWidget {
  @override
  GroupInitScreenState createState() => new GroupInitScreenState();
}

class GroupInitScreenState extends State<GroupInitScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Set Group Info'),
        actions: <Widget>[
        ],
      ),
      // body is the majority of the screen.
      body: Center(
        child: Text('Hello, world!'),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Add',
          child: Icon(
              Icons.done),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          onPressed: () {

          }
      ),
    );
  }
}
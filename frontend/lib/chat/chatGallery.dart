import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
// Uncomment lines 7 and 10 to view the visual layout at runtime.
//import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

class ChatGallery extends StatefulWidget {
  @override
  createState() => ChatGalleryState();
}

class ChatGalleryState extends State<ChatGallery> {
  Size deviceSize;

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT GALLERY',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: deviceSize.height,
        child: Column(
          children: <Widget>[
            DropdownMenu(),
            GalleryPart(),
          ],
        ),
      ), //new ChatSettingsScreen(),
    );
  }
}

class DropdownMenu extends StatelessWidget {
  List<String> _options = ["Sender", "Features"];
  String _option = "Sender";

  @override
  void initState() {
    _option = _options.elementAt(0);
  }

  @override
  void setState(String option) {
    _option = option;
  }

  void onChanged(String option) {
    setState(option);
  }

  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new DropdownButton(
          value: _option,
          items: _options.map((String option) {
            return new DropdownMenuItem(value: option, child: new Text(option));
          }).toList(),
          onChanged: (String option) {
            setState(option);
          },
        ),
      ],
    );
  }
}

class GalleryPart extends StatelessWidget {

  List<Widget> _buildGridTiles(numberOfTiles) {
    List<Container> containers =
        new List<Container>.generate(numberOfTiles, (int index) {
      //index = 0, 1, 2,...
      final imageName = index < 9
          ? 'images_1/image0${index + 1}.JPG'
          : 'images_1/image${index + 1}.JPG';
      return new Container(
        child: new Image.asset(imageName, fit: BoxFit.fill),
      );
    });
    return containers;
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return new Container(
      height: deviceSize.height/3,
      child: Flex(
        direction: Axis.vertical,
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        Text(
          "Type",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
        ),
        GridView.extent(
          shrinkWrap: true,
          maxCrossAxisExtent: 150.0,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          padding: const EdgeInsets.all(5.0),
          children: _buildGridTiles(15), //Where is this function ?
        ),
        Text(
          "Type12",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
        ),
        GridView.extent(
          shrinkWrap: true,
          maxCrossAxisExtent: 150.0,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          padding: const EdgeInsets.all(5.0),
          children: _buildGridTiles(7), //Where is this function ?
        ),
      ],
    )

        /* child: GridView.extent(
        maxCrossAxisExtent: 150.0,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        padding: const EdgeInsets.all(5.0),
        children: _buildGridTiles(15),//Where is this function ?
        ),  */
        );
  }
}

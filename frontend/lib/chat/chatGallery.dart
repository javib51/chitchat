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
            DropDownMenu(),
            GalleryPart(),
          ],
        ),
      ), //new ChatSettingsScreen(),
    );
  }
}

class DropDownMenu extends StatefulWidget {
   @override
   createState() => DropdownMenuState();
}
class DropdownMenuState extends State<DropDownMenu> {
  List<String> _options = ["Sender", "Features"].toList();
  String _option;

  @override
  void initState() {
    _option = _options.first;
    super.initState();
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final dropdownMenuOptions = _options
      .map((String option) =>
          new DropdownMenuItem<String>(value: option, child: new Text(option))
        ).toList();

    return new Container(
      height: deviceSize.height / 10,
      child: Center(
        child: DropdownButton(
          value: _option,
          items: dropdownMenuOptions,
          onChanged: (value) {
            setState(() => this._option = value);
          },
        ),
      ),
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
      height: deviceSize.height / 1.4,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(15.0),
        children: <Widget>[
          Center(
              child: Text(
            "Type",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
          )),
          IgnorePointer(
            ignoring: true,
            child: GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 150.0,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              padding: const EdgeInsets.all(5.0),
              children: _buildGridTiles(10), //Where is this function ?
            ),
          ),
        ],
      ),
    );
  }
}

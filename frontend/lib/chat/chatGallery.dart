import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
// Uncomment lines 7 and 10 to view the visual layout at runtime.
//import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

/* class ChatGallery extends StatefulWidget {
  @override
  createState() => ChatGalleryState();
} */

class ChatGallery extends StatelessWidget {
  final option = new ValueNotifier("Sender");
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT GALLERY',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: option,
        builder: (context, value, child) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                DropDownMenu(
                  option: option,
                ),
                GalleryPart(
                  option: option,
                ),
              ],
            ),
          );
        },
      ), //new ChatSettingsScreen(),
    );
  }
}

class DropDownMenu extends StatefulWidget {
  final List<String> _options = ["Sender", "Features"].toList();
  ValueListenable<String> option;
  DropDownMenu({Key key, @required this.option}) : super(key: key);

  @override
  createState() => DropdownMenuState(this.option);
}

class DropdownMenuState extends State<DropDownMenu> {
  ValueListenable<String> option;
  DropdownMenuState(this.option);
  //final option = new ValueNotifier("Sender");
  //ValueListenable<String> _option;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final dropdownMenuOptions = widget._options
        .map((String option) => new DropdownMenuItem<String>(
            value: option, child: new Text(option)))
        .toList();

    return new Container(
      height: deviceSize.height / 10,
      child: ValueListenableBuilder<String>(
        valueListenable: widget.option,
        builder: (context, valueListened, child) {
          return Center(
            child: DropdownButton(
              value: valueListened,
              items: dropdownMenuOptions,
              onChanged: (value) {
                print("BEFORE " + valueListened);
                valueListened = value;
                print("AFTER " + valueListened);
              },
            ),
          );
        },
      ),
    );
  }
}

class GalleryPart extends StatefulWidget {
  ValueListenable<String> option;

  GalleryPart({Key key, @required this.option}) : super(key: key);

  @override
  createState() => GalleryPartState(this.option);
}

class GalleryPartState extends State<GalleryPart> {
  ValueListenable<String> option;

  GalleryPartState(this.option);
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

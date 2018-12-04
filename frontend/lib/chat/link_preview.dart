import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class LinkPreview extends StatefulWidget {
  final int start;
  final int end;
  final String text;
  final bool isLast;

  LinkPreview(this.text, this.start, this.end, this.isLast);

  @override
  _LinkPreviewState createState() => _LinkPreviewState(text, start, end, isLast);
}

class _LinkPreviewState extends State<LinkPreview> {
  final int start;
  final int end;
  final String text;
  final bool isLast;
  final metadataLink = "https://linkpreview.p.mashape.com/?q=";

  _LinkPreviewState(this.text, this.start, this.end, this.isLast);

  Future<Map<String, dynamic>> _getMetadata() async {
    String link = text.substring(this.start, this.end);
    print("Matched URL: $link");
    final response = await http.get(metadataLink + link, headers: {"X-Mashape-Key": "pLHxkWF3oSmshzAwMPuPzIDzJKD8p1JFDlkjsnSDrp1Fvoj9TZ", "Accept": "application/json"});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load link');
    }
  }

  @override
  Widget build(BuildContext context) {      //Called once for every message to show

    String url = this.text.substring(this.start, this.end);

    return FutureBuilder(
        future: this._getMetadata(),
        builder: (context, snapshot) {
          print(snapshot.connectionState);
          if (snapshot.hasData) {
            print(snapshot.data);
          } else {
            print(snapshot.error);
          }
          return Container(
            child: Column(
              children: <Widget>[
                RichText(text: TextSpan(text: this.text.substring(0, this.start), style: TextStyle(color: primaryColor), children: <TextSpan>[
                  TextSpan(text: url, style: TextStyle(decoration: TextDecoration.underline, color: Colors.lightBlue)),
                  TextSpan(text: this.text.substring(this.end, this.text.length))
                ]), textAlign: TextAlign.left,),
                Divider(),
                Text("$url\n", style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.left),
                Text("${snapshot.hasData ? snapshot.data["description"] : ""}", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                Divider(),
                Container(
                    child: Material(
                      child:
                      GestureDetector(
                        onTap: () async {
                          if (snapshot.connectionState == ConnectionState.done) this._openURL(url);
                        },
                        child: snapshot.connectionState != ConnectionState.done ?
                        Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: greyColor2,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ) :
                        CachedNetworkImage(
                          placeholder: Container(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 200.0,
                            height: 200.0,
                            padding: EdgeInsets.all(70.0),
                            decoration: BoxDecoration(
                              color: greyColor2,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                          errorWidget: Material(
                            child: Image.asset(
                              'images/img_not_available.jpeg',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          imageUrl: snapshot.hasData? snapshot.data["image"] : "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/No_image_available_600_x_450.svg/600px-No_image_available_600_x_450.svg.png",       //Called with the correct value when the async task completes.
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    margin: EdgeInsets.only(bottom: isLast ? 20.0 : 10.0, right: 10.0),
                )
              ],
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: this.isLast ? 20.0 : 10.0, right: 10.0),
          );
        }
    );
  }

  void _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: "Cannot open selected URL");
    }
  }
}
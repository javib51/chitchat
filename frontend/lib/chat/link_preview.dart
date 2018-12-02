import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

Match getLinkMatchFromText(String text) {
  RegExp regex = new RegExp(
          "(?:(?:(?:https?):)?\\/\\/)" +
          "(?:\\S+(?::\\S*)?@)?" +
          "(?:" +
          "(?!(?:10|127)(?:\\.\\d{1,3}){3})" +
          "(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})" +
          "(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})" +
          "(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])" +
          "(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}" +
          "(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))" +
          "|" +
          "(?:" +
          "(?:" +
          "[a-z0-9\\u00a1-\\uffff]" +
          "[a-z0-9\\u00a1-\\uffff_-]{0,62}" +
          ")?" +
          "[a-z0-9\\u00a1-\\uffff]\\." +
          ")+" +
          "(?:[a-z\\u00a1-\\uffff]{2,}\\.?)" +
          ")" +
          "(?::\\d{2,5})?" +
          "(?:[/?#]\\S*)?"
  );
  return regex.firstMatch(text);
}

class LinkPreview extends StatefulWidget {
  final Match match;
  final String text;
  final bool isLast;

  LinkPreview(this.text, this.match, this.isLast);

  @override
  _LinkPreviewState createState() => _LinkPreviewState(text, match, isLast);
}

class _LinkPreviewState extends State<LinkPreview> {
  final Match match;
  final String text;
  final bool isLast;
  final metadataLink = "https://linkpreview.p.mashape.com/?q=";

  _LinkPreviewState(this.text, this.match, this.isLast);

  Future<Map<String, dynamic>> getMetadata() async {
    String link = text.substring(this.match.start, this.match.end);
    print("Matched URL: $link");
    final response = await http.get(metadataLink + link, headers: {"X-Mashape-Key": "pLHxkWF3oSmshzAwMPuPzIDzJKD8p1JFDlkjsnSDrp1Fvoj9TZ", "Accept": "application/json"});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load link');
    }
  }

  Widget getImage(String photoUrl) {
    return Container(
        child: new OverflowBox(
            minWidth: 0.0,
            minHeight: 0.0,
            maxWidth: double.infinity,
            child: new CachedNetworkImage(
              imageUrl: photoUrl,
              errorWidget: new Icon(Icons.photo),
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    String url = this.text.substring(this.match.start, this.match.end);
    return FutureBuilder(
        future: this.getMetadata(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Text(
                this.text,
                style: TextStyle(color: primaryColor),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(bottom: this.isLast ? 20.0 : 10.0, right: 10.0),
            );
          } else {
            print(snapshot.data);
            return  Container(
              child: Column(
                children: <Widget>[
                  RichText(text: TextSpan(text: this.text.substring(0, this.match.start), style: TextStyle(color: primaryColor), children: <TextSpan>[
                    TextSpan(text: url, style: TextStyle(decoration: TextDecoration.underline, color: Colors.lightBlue)),
                    TextSpan(text: this.text.substring(this.match.end, this.text.length))
                  ]), textAlign: TextAlign.left,),
                  Divider(),
                  Text("$url\n", style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.left),
                  Text("${snapshot.data["description"]}", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  Divider(),
                  Material(
                    child:
                      GestureDetector(
                        onTap: () async {
                          this._openURL(url);
                        },
                        child: CachedNetworkImage(
                          placeholder: Container(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 200.0,
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
                          imageUrl: snapshot.data["image"] ?? "http://www.alterenterprise.com/wp-content/uploads/2014/02/Image-not-available_1.jpg",
                          width: 200.0,
//                      height: 200.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                  )
                ],
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),

              width: 200.0,
              decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(bottom: this.isLast ? 20.0 : 10.0, right: 10.0),
            );
          }
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
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/const.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

String getLinkFromText(String text) {
  RegExp regExp = new RegExp(
    r"(http|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?",
    caseSensitive: false,
    multiLine: false,
  );
  return regExp.stringMatch(text)?.toString();
}

class LinkPreview extends StatefulWidget {
  final String link;
  final String text;
  final bool isLast;

  LinkPreview(this.text, this.link, this.isLast);

  @override
  _LinkPreviewState createState() => _LinkPreviewState(text, link, isLast);
}

class _LinkPreviewState extends State<LinkPreview> {
  final String link;
  final String text;
  final bool isLast;
  final metadataLink = "https://linkpreview.p.mashape.com/?q=";

  _LinkPreviewState(this.text, this.link, this.isLast);

  Future<Map<String, dynamic>> getMetadata() async {
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

  void launchUrl() {
    canLaunch(link).then((condition) {
      if (condition) {
        launch(link);
      } else {
        throw 'Could not launch $link';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            return Container(
              child: Column(
                children: <Widget>[
                  Wrap(
                      spacing: 0,
                      alignment: WrapAlignment.end,
                      direction: Axis.vertical,
                      runSpacing: 0,
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text("${this.text}\n\n"),
                              Divider(),
                              Text("${snapshot.data["url"]}\n", style: TextStyle(fontStyle: FontStyle.italic)),
                              Text("${snapshot.data["description"]}", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),

                          width: 200.0,
                          decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(bottom: this.isLast ? 20.0 : 10.0, right: 10.0),
                        ),
                      ]
                  ),
                  Container(
                      child: Material(
                          child:
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
                            imageUrl: snapshot.data["image"] ?? "http://www.alterenterprise.com/wp-content/uploads/2014/02/Image-not-available_1.jpg",
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                      ),
                    margin: EdgeInsets.only(bottom: this.isLast ? 20.0 : 10.0, right: 10.0),
                  )
                ],
              ),
            );
          }
        }
    );
  }
}
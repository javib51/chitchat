import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/const.dart';
import 'package:chitchat/common/translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:io';


class LinkPreview extends StatefulWidget {
  final int start;
  final int end;
  final String text;
  final bool isLast;
  final TranslationLanguage translationLanguage;
  final bool isTranslationAutomatic;

  LinkPreview(this.text, this.start, this.end, this.isLast, this.translationLanguage, this.isTranslationAutomatic);

  @override
  _LinkPreviewState createState() => _LinkPreviewState(text, start, end, isLast, translationLanguage, isTranslationAutomatic);
}

class _LinkPreviewState extends State<LinkPreview> {

//  void configureHTTPClient() {
//    this.httpClient = HttpClient();
//    this.httpClient.connectionTimeout = const Duration(seconds: 5);
//  }

  final int start;
  final int end;
  final String text;
  final bool isLast;
  final metadataLink = "http://api.linkpreview.net/?key=5c03f213e43186a507b2fbb6d682839d872bbf57343b0&q=";
//  HttpClient httpClient;
  final TranslationLanguage translationLanguage;
  final _translator = GoogleTranslator();
  final bool isTranslationAutomatic;

  Future<Map<String, dynamic>> _messageMetadataFuture;

  bool _isTranslating = false;
  String _translatedMessage;

  _LinkPreviewState(this.text, this.start, this.end, this.isLast, this.translationLanguage, this.isTranslationAutomatic);

  @override
  void initState() {
    this._messageMetadataFuture = this._getMessageMetadata();
//    this.configureHTTPClient();
  }

  Future<Map<String, dynamic>> _getMessageMetadata() async {

    Map<String, dynamic> linkPreview;

    try {
      linkPreview = await this._getLinkPreview();
    } catch (e) {
      linkPreview = Map();
    }

    if (this.isTranslationAutomatic) {
      String messageTranslation = await this._getMessageTranslation();
      linkPreview.putIfAbsent("messageTranslated", () => messageTranslation);
    }

    print("getMessageMetadata() value: ${linkPreview}");

    return linkPreview;
  }

  Future<String> _getMessageTranslation() async {
    return await this._translator.translate(this.text, to: getCountryISOCode(this.translationLanguage));
  }

  Future<Map<String, dynamic>> _getLinkPreview() async {
    String link = text.substring(this.start, this.end);
    print("Matched URL: $link");

    print("Final query: ${metadataLink + link}");
    String response = await http.read(metadataLink + link).timeout(const Duration(seconds: 3));

    return json.decode(response);
  }

  Widget _buildTranslationWidget(dynamic snapshot) {
    print("Build translation widget!");
    print("Automatic translation? ${this.isTranslationAutomatic}");
    if (this.isTranslationAutomatic) {
      print("A");
      return Column(
        children: <Widget>[
          Divider(),
          Text(snapshot.hasData
              ? "MESSAGE TRANSLATED TO ${getTranslationLanguageUsableString(
              this.translationLanguage)}\n\n ${snapshot
              .data["messageTranslated"]}"
              : "TRANSLATING MESSAGE TO ${getTranslationLanguageUsableString(
              this.translationLanguage)}",
              style: TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.left),
        ],
      );
    } else {
      if (!this._isTranslating && this._translatedMessage == null) {      //Idle state for on-demand translation
        print("B");
        return Container();
      } else {
        print("C");
        return Column(
          children: <Widget>[
            Divider(),
            Text(!this._isTranslating ? "MESSAGE TRANSLATED TO ${getTranslationLanguageUsableString(this.translationLanguage)}\n\n ${this._translatedMessage}" : "TRANSLATING MESSAGE TO ${getTranslationLanguageUsableString(this.translationLanguage)}", style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.left),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {      //Called once for every message to show

    String url = this.text.substring(this.start, this.end);

    return FutureBuilder(
        future: this._messageMetadataFuture,
        builder: (context, snapshot) {
          print(snapshot.connectionState);
          if (snapshot.hasData) {
            print(snapshot.data);
          }
          if (snapshot.error != null) {
            print(snapshot.error);
          }

          return Container(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onLongPress: () async {
                    print("LongPressed!");
                    if (this.isTranslationAutomatic) return;
                    this.setState(() { this._isTranslating = true;
                    });

                    this._getMessageTranslation().then((translatedString) {
                      this.setState(() {
                        this._isTranslating = false;
                        this._translatedMessage = translatedString;
                      });
                    });
                  },
                  child: RichText(text: TextSpan(text: this.text.substring(0, this.start), style: TextStyle(color: primaryColor), children: <TextSpan>[
                    TextSpan(text: url, style: TextStyle(decoration: TextDecoration.underline, color: Colors.lightBlue)),
                    TextSpan(text: this.text.substring(this.end, this.text.length))
                  ]), textAlign: TextAlign.left,),
                ),
                this._buildTranslationWidget(snapshot),
                Divider(),
                RichText(
                  text: TextSpan(text: "URL found: ", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: url, style: TextStyle(decoration: TextDecoration.underline, color: Colors.lightBlue)),
                  ]
                )),
                snapshot.hasData && snapshot.data["description"] != null ?
                  Text(snapshot.data["description"], style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor), textAlign: TextAlign.left)
                : Container(),
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
                          imageUrl: snapshot.hasData && snapshot.data["image"] != null ? snapshot.data["image"] : "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/No_image_available_600_x_450.svg/600px-No_image_available_600_x_450.svg.png",       //Called with the correct value when the async task completes.
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
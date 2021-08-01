import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:clipboard/clipboard.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permissions_plugin/permissions_plugin.dart';

class saver extends StatefulWidget {
  @override
  _saverState createState() => _saverState();
}
TextEditingController _textEditingController = TextEditingController();


class _saverState extends State<saver> {
  DateTime dateTime = DateTime.now();
  String url = '';
  String displayUrl = '';
  bool is_video = false;

  Future getUrl()async{
    if('${_textEditingController.text.split('/')[4]}'.length<=12){
      var response = await http.get('${_textEditingController.text.split('/')[0]}//${_textEditingController.text.split('/')[2]}/'
          '${_textEditingController.text.split('/')[3]}/''${_textEditingController.text.split('/')[4]}/?__a=1');
      var Json = json.decode(response.body);
      if(Json['graphql']['shortcode_media']['is_video']){
        setState(() {
          is_video = true;
          url = Json['graphql']['shortcode_media']['video_url'];
          displayUrl = Json['graphql']['shortcode_media']['display_url'];
        });
        print(url);
      }
      else{
        setState(() {
          is_video = false;
          url = Json['graphql']['shortcode_media']['display_url'];
          displayUrl = Json['graphql']['shortcode_media']['display_url'];
        });
      }
    }
    else{
      Fluttertoast.showToast(msg: 'This post is private');
    }
    return url;
  }

  Future prmsn(String url) async{
    Map<Permission, PermissionState> permission = await PermissionsPlugin
        .checkPermissions([
      Permission.READ_EXTERNAL_STORAGE,
      Permission.WRITE_EXTERNAL_STORAGE
    ]);
    if( permission[Permission.READ_EXTERNAL_STORAGE] != PermissionState.GRANTED ||
        permission[Permission.WRITE_EXTERNAL_STORAGE] != PermissionState.GRANTED) {
      try {
        permission = await PermissionsPlugin
            .requestPermissions([
          Permission.READ_EXTERNAL_STORAGE,
          Permission.WRITE_EXTERNAL_STORAGE
        ]);
      } on Exception {
        debugPrint("Error");
      }
    }
    if( permission[Permission.READ_EXTERNAL_STORAGE] == PermissionState.GRANTED &&
        permission[Permission.WRITE_EXTERNAL_STORAGE] == PermissionState.GRANTED){
      if(is_video){
        String savePath = "storage/emulated/0/Indian Insta/${dateTime.millisecondsSinceEpoch}.mp4";
        await Dio().download(url, savePath);
        final result = await ImageGallerySaver.saveFile(savePath);
        print(result);
        print(savePath);
        Fluttertoast.showToast(msg: 'Video saved to the gallery', toastLength: Toast.LENGTH_LONG);
      }
      else{
        String savePath = "storage/emulated/0/Indian Insta/${dateTime.millisecondsSinceEpoch}.jpg";
        await Dio().download(url, savePath);
        final result = await ImageGallerySaver.saveFile(savePath);
        print(result);
        print(savePath);
        Fluttertoast.showToast(msg: 'Image saved to the gallery', toastLength: Toast.LENGTH_LONG);
      }
    }
    print("Login ok");
    if(permission[Permission.WRITE_EXTERNAL_STORAGE] == PermissionState.DENIED &&
        permission[Permission.READ_EXTERNAL_STORAGE] == PermissionState.DENIED){
      Fluttertoast.showToast(msg: 'Permission Denied. Please enable the permission from settings to download the file');
    }
  }

  @override
  Widget build(BuildContext context) {
    getUrl();
    final Size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Text('IG Post Downloader', style: TextStyle(fontSize: 30, color: Colors.orangeAccent, fontFamily: 'Poppins'),),
            SizedBox(height: 20,),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Paste your link here',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async{
                    FlutterClipboard.paste().then((value) => {
                      _textEditingController.text = value
                    });
                  },
                  child: Container(
                      height: 50,
                      width: 140,
                      decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Paste', style: TextStyle(color: Colors.white, fontSize: 20),),
                        ],
                      )
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    getUrl();
                  },
                  child: Container(
                      height: 50,
                      width: 140,
                      decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('DOWNLOAD', style: TextStyle(color: Colors.white, fontSize: 18),),
                        ],
                      )
                  ),
                )
              ],
            ),
            SizedBox(height: Size.height/5,),
            FutureBuilder(
                future: getUrl(),
                builder: (context, snapshot){
              if(snapshot.data!= null){
                return Stack(
                  children: [
                    Image.network(url),
                    Positioned(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(icon: Icon(Icons.save_alt, color: Colors.orangeAccent, size: 50,), onPressed: (){
                                prmsn(url);
                              })
                            ],
                          ),
                          width: Size.width,
                        ),
                        bottom: 7,)
                  ],
                );
              }
              else{
                return Center();
              }
            })
          ],
        ),
      )
    );
  }
}

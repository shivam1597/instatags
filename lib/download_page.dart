import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:http/http.dart' as http;

class download extends StatefulWidget {

  final String url;
  download({this.url});
  @override
  _downloadState createState() => _downloadState();
}

class _downloadState extends State<download> {

  DateTime dateTime =DateTime.now();

  Future prmsn() async{
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
      if(url[0].is_Video){
        String savePath = "storage/emulated/0/Indian Insta/${dateTime.millisecondsSinceEpoch}.mp4";
        await Dio().download(url[0].imgUrl, savePath);
        final result = await ImageGallerySaver.saveFile(savePath);
        print(result);
        print(savePath);
        Fluttertoast.showToast(msg: 'Video saved to the gallery', toastLength: Toast.LENGTH_LONG);
      }
      else{
        String savePath = "storage/emulated/0/Indian Insta/${dateTime.millisecondsSinceEpoch}.jpg";
        await Dio().download(url[0].imgUrl, savePath);
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
  String receive;
  String imgUrl;
  List<String> splitted = [];
  List<downLoad> url = [];
  Future<List<downLoad>> getUrl() async{
    var response = await http.get('${splitted[0]}//${splitted[2]}/${splitted[3]}/${splitted[4]}/?__a=1');
    var Json = json.decode(response.body);
    downLoad Download = downLoad(Json['graphql']['shortcode_media']['display_url'], Json['graphql']['shortcode_media']['is_video']);
    url.add(Download);
    print(url[0].is_Video);
    return url;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      receive = this.widget.url;
      splitted = receive.split('/');
    });
  }


  @override
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          width: Size.width,
          height: Size.height,
          child: FutureBuilder(
            future: getUrl(),
            builder: (context, snapshot){
              if(snapshot.data != null){
                return Column(
                  children: [
                    Image.network(url[0].imgUrl),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: () async{
                        prmsn();
                      },
                      child: Container(
                          width: Size.width/2,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.orange[300]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Download', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),),
                            ],
                          )
                      ),
                    )
                  ],
                );
              }
              else{
                return  Column(
                  children: [
                    Image.network('https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-15.png'),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: () async{
                        prmsn();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('This post is private post.', style: TextStyle(color: Colors.orangeAccent, fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),),
                        ],
                      )
                    )
                  ],
                );
              }
            },
          )
      ),
    );
  }
}

class downLoad{
  String imgUrl;
  bool is_Video;
  downLoad(this.imgUrl, this.is_Video);
}
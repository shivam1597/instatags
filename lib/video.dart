import 'dart:ui';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
class videplayer extends StatefulWidget {

  final videoData;
  videplayer({this.videoData});

  @override
  _videplayerState createState() => _videplayerState();
}

class _videplayerState extends State<videplayer> {
  

  FlickManager flickManager;

  @override
  void initState() {
    flickManager = FlickManager(
      videoPlayerController:
      VideoPlayerController.network(this.widget.videoData.code),
    );
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    flickManager.dispose();

    super.dispose();
  }

  int tapCount = 0;
  DateTime dateTime = DateTime.now();

  red() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "instatags/${dateTime.millisecondsSinceEpoch}.mp4";
    print(appDocDir.path);
    print(savePath);
  }

  @override
  Widget build(BuildContext context) {
    red();
    String caption = this.widget.videoData.captions[0]['node']['text'];
    List splits = [];
    List finalSplits = [];
    splits = caption.split('#');
    splits.removeAt(0);
    for (var v in splits){
      finalSplits.add('#'+v);
    }
    var finTxt = finalSplits.toString();

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
          String savePath = "storage/emulated/0/Indian Insta/${dateTime.millisecondsSinceEpoch}.mp4";
          await Dio().download("${this.widget.videoData.code}", savePath);
          final result = await ImageGallerySaver.saveFile(savePath);
          print(result);
          print(savePath);
        Fluttertoast.showToast(msg: 'Video saved to the gallery', toastLength: Toast.LENGTH_LONG);
      }
      print("Login ok");
      if(permission[Permission.WRITE_EXTERNAL_STORAGE] == PermissionState.DENIED &&
          permission[Permission.READ_EXTERNAL_STORAGE] == PermissionState.DENIED){
        Fluttertoast.showToast(msg: 'Permission Denied. Please enable the permission from settings to download the file');
      }
    }

    final Size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save_alt),
        backgroundColor: Colors.orangeAccent,
        onPressed: (){
          prmsn();
        },
      ),
      body: Container(
        child: Stack(
          children: [
            FlickVideoPlayer(
              flickManager: flickManager,
              flickVideoWithControls: FlickVideoWithControls(
                videoFit: BoxFit.contain,
                controls: FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                controls: FlickLandscapeControls(),
              ),
            ),
           Positioned(
                top: Size.height/40,
                child: Container(
                  width: Size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10,),
                      Row(children: [
                        SizedBox(width: 5,),
                        Text('Tags Used: ', style: TextStyle(fontFamily: 'Poppins', color: Colors.orangeAccent),),
                        Text('(Long press on tags to copy)', style: TextStyle(fontSize: 12, color: Colors.white),)
                      ],),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        child: Text('${finTxt.replaceAll(']', '').replaceAll('[', '').replaceAll(',', '')}', style: TextStyle(color: Colors.blue[400], fontFamily: 'Poppins',
                            fontSize: 12
                        ),
                          overflow: TextOverflow.ellipsis, maxLines: 9,),
                        onLongPress: (){
                          ClipboardManager.copyToClipBoard(finTxt.replaceAll(']', '').replaceAll('[', '').replaceAll(',', '')).then((result){
                            Fluttertoast.showToast(msg: 'Tags copied.',textColor: Colors.white, toastLength: Toast.LENGTH_SHORT);
                          });
                        },
                      )
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
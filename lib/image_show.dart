import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

DateTime dateTime = DateTime.now();

class imgshow extends StatefulWidget {

  var showValue;
  imgshow({this.showValue,});

  @override
  _imgshowState createState() => _imgshowState();
}

class _imgshowState extends State<imgshow> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var recvdValue;
  String page = '';

  Future<void> getpage() async {
    final SharedPreferences prefs = await _prefs;
    page = prefs.getString('page');
  }

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
      var response = await Dio().get(recvdValue.url, options: Options(
          responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: '${dateTime.millisecondsSinceEpoch}',
      );
      Fluttertoast.showToast(msg: 'Saved to the gallery', toastLength: Toast.LENGTH_LONG);
    }
    print("Login ok");
    if(permission[Permission.WRITE_EXTERNAL_STORAGE] == PermissionState.DENIED &&
        permission[Permission.READ_EXTERNAL_STORAGE] == PermissionState.DENIED){
      Fluttertoast.showToast(msg: 'Permission Denied. Please enable the permission from settings to download the file');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recvdValue = this.widget.showValue;
    getpage();
  }

  @override
  Widget build(BuildContext context) {

    String caption = recvdValue.captions[0]['node']['text'];

    List splits = [];
    List finalSplits = [];
    splits = caption.split('#');
    splits.removeAt(0);
    for (var v in splits){
      finalSplits.add('#'+v);
    }
    var finTxt = finalSplits.toString();

    final Size = MediaQuery.of(context).size;
    DateTime dateTime = DateTime.now();
    print(dateTime.millisecondsSinceEpoch);

    Future back() async{
      Navigator.pop(context, 'hi');
    }
    double _scale = 1.0;
    return Scaffold(
      body: WillPopScope(
        onWillPop: (){
          return back();
        },
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                GestureDetector(
                  child: InteractiveViewer(
                    minScale: _scale,
                    maxScale: 2,
                    child: Image.network(recvdValue.url, fit: BoxFit.fill,),
                    onInteractionEnd: (ScaleEndDetails details){
                    },
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Container(
                        height: Size.height/20,
                        width: 90,
                        child: Icon(CupertinoIcons.share_up, color: Colors.white,),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                      onTap: () async{
                        var request = await HttpClient().getUrl(Uri.parse(recvdValue.url));
                        var response = await request.close();
                        Uint8List bytes = await consolidateHttpClientResponseBytes(response);
                        await Share.file('Use ${finTxt.replaceAll(']', '').replaceAll('[', '').replaceAll(',', '')} to increase followers on Instagram.'
                            'Download the app from the Google Play for more. ', 'amlog.jpg', bytes, 'image/jpg');
                      },
                    ),
                    SizedBox(width: Size.width/10,),
                    GestureDetector(
                      child: Container(
                        height: Size.height/19.5,
                        width: 90,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 35,
                              top: 5,
                              child: Icon(CupertinoIcons.down_arrow, color: Colors.white,),
                            ),
                            Positioned(
                              left: 35,
                              top: 15,
                              child: Text('____', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                      onTap: () async{
                        prmsn();
                      },
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10,),
                    Row(children: [
                      SizedBox(width: 5,),
                      Text('Tags Used: ', style: TextStyle(fontFamily: 'Poppins', color: Colors.orangeAccent),),
                      Text('(Long press on tags to copy)', style: TextStyle(fontSize: 12),)
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
                          Fluttertoast.showToast(msg: 'Tags copied.', toastLength: Toast.LENGTH_SHORT);
                        });
                      },
                    )
                  ],
                ),
                SizedBox(height: 40,),
                GestureDetector(
                  onTap: () async{
                    String url = 'https://www.instagram.com/p/${recvdValue.shortcode}/';
                    if (await canLaunch(url)) {
                    await launch(url, forceSafariVC: false);
                    } else {
                    throw 'Could not launch $url';
                    }
                  },
                  child: Container(
                    width: Size.width/2,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.orange[300]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Open in Instagram', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),),
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      )
      );
  }
}

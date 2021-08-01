import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:dio/dio.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart' as NewShare;
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'help.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'download_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'image_show.dart';
import 'tags_result.dart';
import 'video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'ig_saver.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

ScrollController _scrollController;

class show{
  var captions;
  String shortcode;
  String url;
  show({this.url, this.captions, this.shortcode});
}

class vdata{
  String code;
  var captions;
  vdata({this.code, this.captions});
}

class sendTag{
  String tag;
  sendTag({this.tag});
}

String passUrl = '';
var passCaptions;
String searchTage = '';
String passVUrl = '';

String tags1 ='';
String tags2 = '';

String pcode = '';

List<hashtags1> urls1 = [];
List<hashtags2> urls2 = [];

List<String> taglist1 = [
  'tradition',
  'ipl',
  'cricket',
  'diwali',
  'space_time',
  'cosmos',
  'cricket',
  'travel'
];


class _homePageState extends State<homePage> {

  FocusNode focusNode = FocusNode();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var vb;
  String _sharedText = '';
  String hintText = 'Enter tags to search posts';

  TextEditingController textEditingController = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  
  Future gettingUrl() async{
    Route route =
    MaterialPageRoute(builder: (context) => download(url: _sharedText,));
    Navigator.push(context, route);
  }
  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tags1 = randomChoice(taglist1);
    tags2 = randomChoice(taglist1);
    while (tags1 == tags2){
      setState(() {
        tags2 = randomChoice(taglist1);
      });
    }
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hintText = '';
      } else {
        hintText = 'Enter tags to search posts';
      }
    });
    StreamSubscription _intentDataStreamSubscription;
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
          setState(() {
            _sharedText = value;
          });
          if(_sharedText != null){
            gettingUrl();
          }
        }, onError: (err) {
          print("getLinkStream error: $err");

        });
    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
      });
      if(_sharedText != null){
        gettingUrl();
      }
    });
  }
  Future getUrl(String url) async{
    var response = await http.get(url);
    var Json = json.decode(response.body);
    print(Json);
    if(Json['graphql']['shortcode_media']['is_video']){
      print('It is video');
    }
    else{
      print('It is image');
    }
  }

  Future<void> setpage(String search) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('tag', search);
  }

  void _navigateSearch(){
    var imag = new sendTag(
        tag: searchTage,
    );
    Route route =
    MaterialPageRoute(builder: (context) => instasearch(getTag: imag,));
    Navigator.push(context, route);

  }

  Future back() async{
    SystemNavigator.pop(animated: true);
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Opacity(
          opacity: 0.1,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: Colors.orangeAccent,
                    ),
                  ],
                )
            ),
          ),
        );
      },
    );
    new Future.delayed(new Duration(seconds: 3), () {
      Navigator.pop(context); //pop dialog
    });
  }

  void _noData() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Recent posts from #$tags2 are currently hidden.'),
          actions: [
            CupertinoButton(child: Text('OK'), onPressed: (){
              Navigator.pop(context);
            }),
            CupertinoButton(child: Text('Open With Instagram'), onPressed: () async{
              String url = 'https://www.instagram.com/explore/tags/$tags2';
              if (await canLaunch(url)) {
                await launch(url, forceSafariVC: false);
              } else {
                throw 'Could not launch $url';
              }
            })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    List strict = ['alone', ' always', ' armparty', ' adulting', ' assday', ' ass', ' abdl', ' assworship', ' addmysc', ' asiangirl', ' beautyblogger',
      ' brain', ' boho', ' besties', ' bikinibody', 'boobs', 'breasts', ' costumes', ' curvygirls',
      ' date', ' dating', ' desk', ' dm', ' direct', ' elevator', ' eggplant', ' edm', ' fuck',
      ' girlsonly', ' gloves', ' graffitiigers',
      ' happythanksgiving', ' hawks', ' hotweather', ' humpday', ' hustler',
      ' ilovemyinstagram', ' instababy', ' instasport', ' iphonegraphy', ' italiano', ' ice',
      ' killingit', ' kansas', ' kissing', ' kickoff', ' leaves', ' like', ' lulu', ' lean',
      ' master', ' milf', ' mileycyrus', ' models', ' mustfollow',
      ' nasty', ' newyearsday', ' nude', ' nudism', ' nudity', 'porn',
      ' overnight', ' orderweedonline', ' parties', ' petite', ' pornfood', ' pushups', ' prettygirl',
      ' rate', ' ravens', ' samelove', ' selfharm', ' skateboarding', ' skype', ' snap', ' snapchat', ' single', ' singlelife', ' stranger',
      ' saltwater', ' shower', ' shit', ' sopretty', ' sunbathing',  'streetphoto', 'swole', 'snowstorm', 'sun', 'sexy',
      'tanlines', 'todayimwearing', 'teens', 'teen', 'thought', 'tag4like', 'tagsforlikes', 'thighs',
      'undies',
      'valentinesday',
      'workflow', 'wtf', 'sexy', 'sex',
      'xanax',
      'youngmodel'
    ];

    final Size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          backgroundColor: Colors.orangeAccent,
          onPressed: (){
            if(strict.contains(tags2)){
              setState(() {
                tags2 = randomChoice(taglist1);
                textEditingController.text = '';
              });
            }
            setState(() {
              getResponse2();
            });
            _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: Duration(milliseconds: 1000), curve: Curves.easeOut);
          }),
      resizeToAvoidBottomPadding: true,
      drawer: Drawer(
        child: GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: Size.width/8,
                    backgroundImage: AssetImage('assets/images/tags_logo.png'),
                  ),
                  SizedBox(width: Size.width/20,),
                  Text('Indian Insta', style: TextStyle(color: Colors.orangeAccent, fontFamily: 'Poppins', fontSize: 22),)
                ],
              ),
              GestureDetector(
                onTap: () async{
                  const url = 'https://play.google.com/store/apps/details?id=com.instatags.trendings.instatags';

                  if (await canLaunch(url)) {
                    await launch(url, forceSafariVC: false);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Container(
                  width: Size.width/1.2,
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.orangeAccent,),
                      SizedBox(width: 10,),
                      Text('Rate', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.orangeAccent),)
                    ],
                  )
                ),
              ),
              GestureDetector(
                onTap: () async{
                  const url = 'https://qwerty1519.blogspot.com/2020/10/insta-trending-tag-posts-tagplus.html';

                  if (await canLaunch(url)) {
                    await launch(url, forceSafariVC: false);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Container(
                    width: Size.width/1.2,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orangeAccent,),
                        SizedBox(width: 10,),
                        Text('About App', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.orangeAccent),)
                      ],
                    )
                ),
              ),
              GestureDetector(
                onTap: (){
                  Share.share('Search trending Insta posts with Tags. ;) Get the app now. https://play.google.com/store/apps/details?id=com.instatags.trendings.instatags ');
                },
                child: Container(
                    width: Size.width/1.2,
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.share, color: Colors.orangeAccent,),
                        SizedBox(width: 10,),
                        Text('Invite Friends', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.orangeAccent),)
                      ],
                    )
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => saver()));
                },
                child: Container(
                  width: Size.width/1.2,
                  child: Row(
                    children: [
                      Icon(Icons.save_alt, color: Colors.orangeAccent,),
                      SizedBox(width: 10,),
                      Text('Save IG posts', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.orangeAccent),)
                    ],
                  )
              ),),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => guide()));
                },
                child: Container(
                    width: Size.width/1.2,
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.orangeAccent,),
                        SizedBox(width: 10,),
                        Text('How To Save Posts?', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.orangeAccent),)
                      ],
                    )
                ),),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Made', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' In', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' India', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' ❤', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          )
        )
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: WillPopScope(
          onWillPop: () async{
            return back();
          },
          child: SingleChildScrollView(
              child: Container(
                  height: Size.height,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: Size.height/30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.menu, size: 30, color: Colors.orangeAccent,),
                          Container(
                              width: 300,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 2.0,
                                    )
                                ),
                                child: TextField(
                                    focusNode: focusNode,
                                    textAlign: TextAlign.center,
                                    cursorColor: Colors.orangeAccent,
                                    controller: textEditingController,
                                    decoration: InputDecoration(
                                      border: new OutlineInputBorder(
                                          borderSide: new BorderSide(color: Colors.teal)
                                      ),
                                      hintText: hintText,
                                      hintStyle: TextStyle(fontSize: 15.0, color: Colors.orange, fontWeight: FontWeight.bold),
                                      fillColor: Colors.orangeAccent[300],
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.orangeAccent),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.orange),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    )
                                ),
                              )
                          ),
                          IconButton(icon: Icon(Icons.search, color: Colors.orange, size: 30,), onPressed: (){
                            if(textEditingController.text.toString() == ''){
                              Fluttertoast.showToast(msg: 'Please enter the tag you want to search');
                            }
                            else{
                              setState(() {
                                tags2 = textEditingController.text.toLowerCase();
                                strict.contains(tags2)?_noData():_onLoading();
                                print(strict.contains(tags2));
                              });
                            }
                          })
                        ],
                      ),
                      scrl1(),
                      Expanded(child: scrl2(),),
                      SizedBox(height: Size.height/13,),
                      SizedBox(height: 4,),
                    ],
                  )
              ),
          ),
        ),
      )
    );
  }
}

class hashtags1{
  String url;
  var captions;
  bool is_video;
  String p_code;
  hashtags1(this.url, this.captions, this.is_video, this.p_code);
}

class hashtags2{
  String url;
  var captions;
  bool is_video;
  String p_code;
  hashtags2(this.url, this.captions, this.is_video, this.p_code);
}

List<String> videoUrl = [];

Future getVideoUrl() async{
  var vresponse = await http.get('https://www.instagram.com/p/$pcode/?__a=1');
  var Json = json.decode(vresponse.body);
  videoUrl.clear();
  videoUrl.add(Json['graphql']['shortcode_media']['video_url']);
  print(videoUrl);
}

class scrl1 extends StatefulWidget {
  @override
  _scrl1State createState() => _scrl1State();
}

class _scrl1State extends State<scrl1> {

  FocusNode focusNode = FocusNode();

  Future<List<hashtags1>> getResponse1()async{
    var response = await http.get('https://www.instagram.com/explore/tags/$tags1/?__a=1');
    var Json = json.decode(response.body);
    urls1.clear();
    for(var v in Json['graphql']['hashtag']['edge_hashtag_to_media']['edges']){
      hashtags1 hashlist1 = hashtags1(v['node']['display_url'], v['node']['edge_media_to_caption']['edges'], v['node']['is_video'], v['node']['shortcode']);
      urls1.add(hashlist1);
    }
    return urls1;
  }

  Future<void> _navigateShow() async {
    var imag = new show(
      shortcode: pcode,
        url: passUrl,
        captions: passCaptions,
    );
    Route route =
    MaterialPageRoute(builder: (context) => imgshow(showValue: imag,));
    Navigator.push(context, route);
  }

  Future<void> _navigateVideo(bool Video) async{
    await getVideoUrl();
    var vid = new vdata(
        code: videoUrl[0],
        captions: passCaptions
    );
    Route route =
    MaterialPageRoute(builder: (context) => videplayer(videoData: vid,));
    Navigator.push(context, route);
  }

  String hintText = '';

  @override
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;
    return Container(
        width: Size.width,
        child: Column(
          children: [
            SizedBox(height: 4,),
            Container(
              padding: EdgeInsets.only(left: 10),
              height: Size.height/6.8,
              width: Size.width,
              child: FutureBuilder(
                future: getResponse1(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.data == null){
                    return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.orangeAccent,
                        )
                    );
                  }
                  else{
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: urls1.length,
                      itemBuilder: (context, index){
                        return GestureDetector(
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(urls1[index].url),
                                  radius: Size.width/8,
                                  backgroundColor: Colors.orange[200],
                                ),
                                urls1[index].is_video? Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_arrow, color: Colors.orangeAccent, size: 45,)
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  ),
                                  height: Size.width*2/8,
                                  width: Size.width*2/8,): Text(' '),
                                Positioned(
                                  child: Text('#$tags1', style: TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold),),
                                  top: 102,
                                  left: 20,
                                )
                              ],
                            ),
                          ),
                          onTap: () async {
                            pcode = urls1[index].p_code;
                            passUrl = urls1[index].url;
                            passCaptions = urls1[index].captions;
                            urls1[index].is_video?_navigateVideo(urls1[index].is_video):_navigateShow();
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        )
    );
  }
}

class scrl2 extends StatefulWidget {
  @override
  _scrl2State createState() => _scrl2State();
}
Future<List<hashtags2>> getResponse2()async{
  var response = await http.get('https://www.instagram.com/explore/tags/$tags2/?__a=1');
  var Json = json.decode(response.body);
  urls2.clear();
  for(var v in Json['graphql']['hashtag']['edge_hashtag_to_media']['edges']){
    hashtags2 hashlist2 = hashtags2(v['node']['display_url'], v['node']['edge_media_to_caption']['edges'], v['node']['is_video'],v['node']['shortcode']);
    urls2.add(hashlist2);
  }
  return urls2;
}
class _scrl2State extends State<scrl2> {

  Future<void> _navigateVideo1(bool Video) async{
    await getVideoUrl();
    var vid = new vdata(
        code: videoUrl[0],
        captions: passCaptions
    );
    Route route =
    MaterialPageRoute(builder: (context) => videplayer(videoData: vid,));
    Navigator.push(context, route);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
  }

  Future prmsn(String url, bool is_video, String code) async{
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
        var vresponse = await http.get('https://www.instagram.com/p/$code/?__a=1');
        var Json = json.decode(vresponse.body);
        videoUrl.clear();
        videoUrl.add(Json['graphql']['shortcode_media']['video_url']);
        String savePath = "storage/emulated/0/Indian Insta/${dateTime.millisecondsSinceEpoch}.mp4";
        await Dio().download(videoUrl[0], savePath);
        final result = await ImageGallerySaver.saveFile(savePath);
        print(result);
        print(savePath);
        Fluttertoast.showToast(msg: 'Video saved to the gallery', toastLength: Toast.LENGTH_LONG);
      }
      else{
        var response = await Dio().get(url, options: Options(
            responseType: ResponseType.bytes));
        await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          name: '${dateTime.millisecondsSinceEpoch}',
        );
        Fluttertoast.showToast(msg: 'Saved to the gallery', toastLength: Toast.LENGTH_LONG);
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
    final Size = MediaQuery.of(context).size;
    return Container(
        width: Size.width,
        child: FutureBuilder(
          future: getResponse2(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.data == null){
              return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.orangeAccent,
                  )
              );
            }
            else{
              return ListView.builder(
                controller: _scrollController,
                itemCount: urls2.length,
                itemBuilder: (context, index){
                  return Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  pcode = urls2[index].p_code;
                                  passUrl = urls2[index].url;
                                  passCaptions = urls2[index].captions;
                                  urls2[index].is_video?_navigateVideo1(urls2[index].is_video): print('no');
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FadeInImage(placeholder: AssetImage('assets/images/tags_logo.png'), image: NetworkImage(urls2[index].url,), height: 240, width: 240,)
                                      ],
                                    )
                                ),
                              ),
                              urls2[index].is_video?Positioned(
                                  top: Size.height/6,
                                  left: Size.width/2.2,
                                  child: Icon(Icons.play_arrow, color: Colors.orangeAccent, size: 60,)):
                              Center()
                            ],
                          ),
                          Text('(Showing post for $tags2)', style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontFamily: 'Poppins'),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(icon: Icon(Icons.save_alt_outlined, color: Colors.orangeAccent, size: 35,),
                                onPressed: (){
                                  prmsn(urls2[index].url, urls2[index].is_video, urls2[index].p_code);
                                },
                              ),
                              IconButton(icon: Icon(Icons.share, color: Colors.orangeAccent, size: 35,),
                                onPressed: () async{
                                  var request = await HttpClient().getUrl(Uri.parse(urls2[index].url));
                                  var response = await request.close();
                                  Uint8List bytes = await consolidateHttpClientResponseBytes(response);
                                  await NewShare.Share.file('Use ${urls2[index].captions} to increase followers on Instagram.'
                                      'Download the app from the Google Play for more. ', 'amlog.jpg', bytes, 'image/jpg');
                                },
                              ),
                              IconButton(icon: Icon(Icons.open_in_new, color: Colors.orangeAccent, size: 35,),
                                onPressed: () async{
                                  String url = 'https://www.instagram.com/p/${urls2[index].p_code}/';
                                  if (await canLaunch(url)) {
                                    await launch(url, forceSafariVC: false);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                              )
                            ],
                          ),
                          Text('(Long press on tags to copy)', style: TextStyle(fontSize: 13),),
                          GestureDetector(
                            onLongPress: (){
                              ClipboardManager.copyToClipBoard('${urls2[index].captions[0]['node']['text']}').then((result){
                                Fluttertoast.showToast(msg: 'Tags copied.', toastLength: Toast.LENGTH_SHORT);
                              });
                            },
                            child: Text('${urls2[index].captions[0]['node']['text']}', style: TextStyle(color: Colors.blue[400], fontFamily: 'Poppins',
                                fontSize: 12
                            ),
                              overflow: TextOverflow.ellipsis, maxLines: 9,),
                          ),
                          Container(
                            height: 3,
                            width: Size.width,
                            color: Colors.orangeAccent,
                          )
                        ],
                      )
                  );
                },
              );
            }
          },
        ),
        );
  }
}
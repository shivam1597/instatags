import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'tag_imgshow.dart';
import 'video.dart';
import 'dart:async';

class instasearch extends StatefulWidget {

  var getTag;
  instasearch({this.getTag});

  @override
  _instasearchState createState() => _instasearchState();
}

String pcode;

class show1{
  String shortcode;
  var captions;
  String url;
  show1({this.url, this.captions, this.shortcode});
}

class _instasearchState extends State<instasearch> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<hashtagsget> urls = [];

  String sharedTag = '';
  Future<List<hashtagsget>> getResponse(String tag)async{
    final SharedPreferences prefs = await _prefs;
    searchTag = prefs.getString('tag');
    var response = await http.get('https://www.instagram.com/explore/tags/$tag/?__a=1');
    var Json = json.decode(response.body);
    print(Json['graphql']['hashtag']['edge_hashtag_to_media']['edges']);
    urls.clear();
    for(var v in Json['graphql']['hashtag']['edge_hashtag_to_media']['edges']){
      hashtagsget Get = hashtagsget(v['node']['display_url'], v['node']['edge_media_to_caption']['edges'], v['node']['is_video'], v['node']['shortcode']);
      urls.add(Get);
    }
    print(urls[1].url);
    return urls;
  }
  String passUrl = '';
  var passCaptions;

  String searchTag = '';

  List<String> videoUrl = [];

  Future getVideoUrl() async{
    var vresponse = await http.get('https://www.instagram.com/p/$pcode/?__a=1');
    var Json = json.decode(vresponse.body);
    videoUrl.clear();
    videoUrl.add(Json['graphql']['shortcode_media']['video_url']);
    print(videoUrl);
  }


  void _navigateShow(){
    var imag = new show1(
      shortcode: pcode,
        url: passUrl,
        captions: passCaptions,
    );
    Route route =
    MaterialPageRoute(builder: (context) => tagimgshow(showValue: imag,));
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

  Future change() async{
    searchTag = sharedTag;
  }

  @override
  void initState() {
    super.initState();
  }

  Future back() async{
    Navigator.pop(context, '/');
  }


  List strict = ['alone, always, armparty, adulting, assday, ass, abdl, assworship, addmysc, asiangirl,',
      'beautyblogger, brain, boho, besties, bikinibody',
      'costumes, curvygirls',
      'date, dating, desk, dm, direct',
      'elevator, eggplant, edm',
      'fuck, girlsonly, gloves, graffitiigers',
      'happythanksgiving, hawks, hotweather, humpday, hustler',
      'ilovemyinstagram, instababy, instasport, iphonegraphy, italiano, ice',
      'killingit, kansas, kissing, kickoff',
      'leaves, like, lulu, lean,',
      'master, milf, mileycyrus, models, mustfollow',
      'nasty, newyearsday, nude, nudism, nudity,',
      'overnight, orderweedonline',
      'parties, petite, pornfood, pushups, prettygirl,',
      'rate, ravens',
      'samelove, selfharm, skateboarding, skype, snap, snapchat, single, singlelife, stranger, saltwater, shower, shit, sopretty, sunbathing, streetphoto, swole, snowstorm, sun, sexy',
      'tanlines, todayimwearing, teens, teen, thought, tag4like, tagsforlikes, thighs',
      'undies',
      'valentinesday',
      'workflow, wtf',
      'xanax',
      'youngmodel'];

  @override
  Widget build(BuildContext context) {
    change();
    searchTag = this.widget.getTag.tag;

    DateTime dateTime = DateTime.now();
    print(dateTime.millisecondsSinceEpoch);

    final Size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        body:WillPopScope(
          onWillPop: () async{
            return  back();
          },
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                    padding: EdgeInsets.only(left: 10),
                    height: Size.height/8,
                    child: Stack(
                      children: [
                        Positioned(
                          child: Text('Showing results for\n #${searchTag} \n  \n', style: TextStyle(color: Colors.orangeAccent, fontSize: 30, fontFamily: 'Poppins'),),
                        ),
                        Positioned(
                          top: Size.height/20,
                          right: 2,
                          child: IconButton(
                            icon: Icon(CupertinoIcons.refresh_thick, size: 40,color: Colors.orangeAccent,),
                            onPressed: () async{
                              setState(() {
                                getResponse(searchTag);
                              });
                            },
                          ),
                        )
                      ],
                    )
                ),
                Expanded(
                  child: strict.contains(searchTag)? Column(
                    children: [
                      Text('Recent posts from #$searchTag are currently hidden on Instagram.', style: TextStyle(color: Colors.green,
                          fontSize: 25, fontFamily: 'Poppins'),),
                      SizedBox(height: 15,),
                      GestureDetector(
                        onTap: () async{
                          String url = 'https://www.instagram.com/explore/tags/$searchTag/';
                          if (await canLaunch(url)) {
                            await launch(url, forceSafariVC: false);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Container(
                            width: Size.width/1.4,
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.orange[300]
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Try Open With Instagram', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),),
                              ],
                            )
                        ),
                      ),
                    ],
                  ):FutureBuilder(
                    future: getResponse(searchTag),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if(snapshot.data == null){
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                      }
                      else{
                        return GridView.count(crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: List.generate(urls.length, (index) {
                            return GestureDetector(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    child: Container(
                                        child: FadeInImage.assetNetwork(placeholder: 'assets/images/tags_logo.png', image: urls[index].url, fit: BoxFit.cover,)
                                    ),
                                  ),
                                  urls[index].is_video? Center(
                                      child: Icon(CupertinoIcons.play_arrow_solid, size: 45, color: Colors.orangeAccent,)): Text(' ')
                                ],
                              ),
                              onTap: () async {
                                pcode = urls[index].p_code;
                                passUrl = urls[index].url;
                                passCaptions = urls[index].captions;
                                urls[index].is_video?_navigateVideo(urls[index].is_video):_navigateShow();
                              },
                            );
                          }),);
                      }
                    },
                  ),
                )
              ],
            ),
            padding: EdgeInsets.only(left: 5, right:4),
          ),
        )
    );
  }
}

class hashtagsget{
  String url;
  var captions;
  bool is_video;
  String p_code;
  hashtagsget(this.url, this.captions, this.is_video, this.p_code);
}

class vdata{
  String code;
  var captions;
  vdata({this.code, this.captions});
}
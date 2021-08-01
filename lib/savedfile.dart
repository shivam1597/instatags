import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thumbnails/thumbnails.dart';
final Directory _videoDir = new Directory('/storage/emulated/0/Indian Insta');

List<Widget> _widgets = <Widget>[
  ImageCapture(),
  VideoListView(),
];

PageController controller=PageController();

class viewpager extends StatefulWidget {
  @override
  _viewpagerState createState() => _viewpagerState();
}

class _viewpagerState extends State<viewpager> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            title: Text('Saved Files'),
            backgroundColor: Colors.orangeAccent,
            automaticallyImplyLeading: false,
            bottom: TabBar(
              tabs: [
                Icon(Icons.image),
                Icon(Icons.movie)
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: _widgets,
        ),
      ),
    );
  }
}


class VideoListView extends StatefulWidget {

  @override
  VideoListViewState createState() {
    return new VideoListViewState();
  }
}

class VideoListViewState extends State<VideoListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!Directory("${_videoDir.path}").existsSync()) {
      return Scaffold(
        body: Container(
          padding: EdgeInsets.only(bottom: 60.0),
          child: Center(
            child: Text("Install WhatsApp\nYour Friend's Status will be available here.", style: TextStyle(
                fontSize: 18.0
            ),),
          ),
        ),
      );
    }
    else{
      return Scaffold(
        body: VideoGrid(directory: _videoDir),
      );
    }
  }
}
class VideoGrid extends StatefulWidget {
  final Directory directory;

  const VideoGrid({Key key, this.directory}) : super(key: key);

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {

  _getImage(videoPathUrl) async {
    //await Future.delayed(Duration(milliseconds: 500));
    String thumb = await Thumbnails.getThumbnail(
        videoFile: videoPathUrl,
        imageType: ThumbFormat.PNG,//this image will store in created folderpath
        quality: 10);
    return thumb;
  }

  String delPath = '';
  var lists;
  String messageShow = '';

  showAlertDialog(BuildContext context){
    final Size = MediaQuery.of(context).size;
    Dialog alert = Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        width: Size.width/1.3,
        height: Size.height/7,
        child: Column(
          children: [
            SizedBox(height: 10,),
            Text('Are you sure you want to delete this video?'),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Container(
                  width: Size.width/2.1,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.orange[300]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Delete this video', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  Future getLists() async{
    lists = widget.directory.listSync().map((item) => item.path).where((item) => item.endsWith(".mp4")).toList(growable: false);
    return lists;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lists = widget.directory.listSync().map((item) => item.path).where((item) => item.endsWith(".mp4")).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    var videoList = widget.directory.listSync().map((item) => item.path).where((item) => item.endsWith(".mp4")).toList(growable: false);
    print(videoList);
    if(lists == null){
      return Center(
        child: Text('No videos found', style: TextStyle(color: Colors.green, fontFamily: 'Poppins', fontSize: 30),),
      );
    }
    else{
      return Container(
          padding: EdgeInsets.only(bottom: 60.0),
          child: FutureBuilder(
            future: getLists(),
            builder: (context, snapshot){
              if(snapshot.data != null){
                return GridView.builder(
                  itemCount: videoList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 8.0/8.0),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(10.0),
                      child: InkWell(
                        onLongPress: (){
                          setState(() {
                            delPath = videoList[index];
                          });
                          showAlertDialog(context);
                        },
                        child: Container(
                          child: FutureBuilder(
                              future: _getImage(videoList[index]),
                              builder: (context, snapshot) {
                                print(videoList);
                                if (snapshot.data != null) {
                                  return Column(
                                      children: <Widget>[
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(30.0),
                                            child: FadeInImage(placeholder: AssetImage('assets/images/tags_logo.png'), image: FileImage(File(snapshot.data)), height: 170, width: 200, fit: BoxFit.cover,)
                                        ),
                                      ]
                                  );
                                }
                                else{
                                  return Center(child: CircularProgressIndicator(),);
                                }
                              }
                          ),
                          //new cod
                        ),
                      ),
                    );
                  },
                );
              }
              else{
                return Text(messageShow);
              }
            },
          )
      );
    }
  }
}
class ImageCapture extends StatefulWidget {
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          builder: (context, status) {
            return ImageGrid(directory: _videoDir);
          },
        ),
      ),
    );
  }
}
class ImageGrid extends StatelessWidget {
  final Directory directory;

  const ImageGrid({Key key, this.directory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var imageList = directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".jpg"))
        .toList(growable: false);
    return GridView.builder(
      itemCount: imageList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 3.0 / 4.6),
      itemBuilder: (context, index) {
        File file = new File(imageList[index]);
        String name = file.path.split('/').last;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              child: Padding(
                padding: new EdgeInsets.all(4.0),
                child: Image.file(
                  File(imageList[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
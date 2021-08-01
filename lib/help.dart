import 'package:flutter/material.dart';

class guide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            Text('How To Save Videos/Images!', style: TextStyle(fontSize: 23,), overflow: TextOverflow.ellipsis,),
            SizedBox(height: 15,),
            Row(
              children: [
                SizedBox(width: 10,),
                Text('1.  '),
                Image.asset('assets/images/20201025_170510_0000.png', height: 350,),
              ],
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                SizedBox(width: 10,),
                Text('2.  '),
                Image.asset('assets/images/20201025_170510_0001.png', height: 350,)
              ],
            ),
            SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: Text('Now you can download the photo/video to your device. ;)', style: TextStyle(fontSize: 20,), ),
                )
              ],
            )
          ],
        ),
      )
    );
  }
}

import 'download_page.dart';
import 'package:instatags/home_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ig_saver.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.shared.init(
      "0d2bf020-18df-49f9-a9cf-5e9d42b0ae5f",
      iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: false
      }
  );
  OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: homePage(),
  ));
}

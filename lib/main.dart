import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_d/splash_screen.dart';
import 'package:hive_flutter/adapters.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  //Here Local Database Hive assign
  await Hive.initFlutter();
  Box box = await Hive.openBox('notepad');
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notepad+',
      theme: ThemeData(
        brightness: Brightness.light,
       // primarySwatch: Colors.green,
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/splash':(context)=>Splash(),
      },
      initialRoute: '/splash',
    );
  }
}



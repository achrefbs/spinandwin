import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spinandwin/ad_state.dart';
import 'package:spinandwin/helper.dart';
import 'package:spinandwin/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final adState = AdState();

  await MobileAds.initialize();
  AppOpenAd appOpenAd = AppOpenAd(unitId: adState.openAdUnitId);
  appOpenAd.load();
  if (!appOpenAd.isAvailable) await appOpenAd.load();
  if (appOpenAd.isAvailable) {
    await appOpenAd.show();
    // Load a new ad right after the other one was closed
    appOpenAd.load();
  }
  runApp(
    Provider.value(
      value: adState,
      builder: (context, child) => App(),
    ),
  );
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Helper>(
          create: (_) => Helper(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return const LoadingScreen();
            }

            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              return const HomePage();
            }

            // Otherwise, show something whilst waiting for initialization to complete
            return const LoadingScreen();
          },
        ),
      ),
    );
  }
}

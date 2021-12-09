import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'package:provider/provider.dart';
import 'package:spinandwin/ad_state.dart';
import 'package:spinandwin/helper.dart';
import 'package:spinandwin/wheel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bannerController = BannerAdController();
  final bannerController2 = BannerAdController();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    bannerController.load();
    bannerController2.load();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    super.dispose();
    bannerController.dispose();
    bannerController2.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _connectivitySubscription.cancel();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (_) {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    AdState adState = Provider.of<AdState>(context);
    Helper helper = Provider.of<Helper>(context);
    return Stack(
      children: [
        Image.asset(
          "assets/background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        if (_connectionStatus != ConnectivityResult.none)
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                SizedBox(
                  height: 50,
                  child: BannerAd(
                    controller: bannerController,
                    size: BannerSize.BANNER,
                    unitId: adState.bannerAdUnit2Id,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/Coin.png",
                      height: 50,
                    ),
                    Text(
                      helper.coins.toString(),
                      style: TextStyle(
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                    color: Colors.grey,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '100',
                        style: TextStyle(color: Colors.white),
                      ),
                      Image.asset(
                        "assets/Coin.png",
                        height: 15,
                      ),
                      const Text(
                        '= 10 DT ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Image.asset(
                        "assets/tt-logo.png",
                        height: 15,
                      ),
                      Image.asset(
                        "assets/Ooredoo.png",
                        height: 15,
                      ),
                      Image.asset(
                        "assets/orange.png",
                        height: 15,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: const Wheel(),
                    width: MediaQuery.of(context).size.width * 0.85,
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: BannerAd(
                    controller: bannerController2,
                    size: BannerSize.BANNER,
                    unitId: adState.bannerAdUnitId,
                  ),
                ),
              ],
            ),
          ),
        if (_connectionStatus == ConnectivityResult.none) const LoadingScreen(),
      ],
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/2.png",
            height: 150,
          ),
          const SizedBox(
            height: 50,
          ),
          const CircularProgressIndicator(),
        ],
      )),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:provider/provider.dart';
import 'package:spinandwin/ad_state.dart';
import 'package:spinandwin/helper.dart';
import 'package:spinandwin/particles.dart';

final gifs = [
  "assets/win1.gif",
  "assets/win2.gif",
  "assets/win3.gif",
  "assets/win4.gif",
  "assets/win5.gif",
  "assets/win6.gif",
  "assets/win9.gif",
];

class WinDialog extends StatefulWidget {
  final BuildContext context;
  // ignore: prefer_typing_uninitialized_variables
  final ticket;
  const WinDialog({Key? key, required this.context, required this.ticket})
      : super(key: key);

  @override
  State<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<WinDialog> {
  final RewardedAd _rewardedAd =
      RewardedAd(unitId: AdState().rewardedAdUnit2Id);
  @override
  void initState() {
    super.initState();
    _rewardedAd.load();
  }

  @override
  Widget build(BuildContext context) {
    Helper helper = Provider.of<Helper>(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.2),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.3, 0.7, 1],
            colors: [Colors.green, Colors.blue, Colors.orange, Colors.pink],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: Image.asset(
                gifs[Random().nextInt(gifs.length)],
              ),
            ),
            PimpedButton(
              particle: Particles(),
              pimpedWidgetBuilder: (context, controller) {
                controller.forward(from: 0.0);
                controller.repeat();
                return FutureBuilder(
                  future: widget.ticket,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length != 0) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '1 DT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                if (helper.ticketWon == Ops.tt)
                                  Image.asset(
                                    'assets/tt-logo.png',
                                    height: 30,
                                  ),
                                if (helper.ticketWon == Ops.ooredoo)
                                  Image.asset(
                                    'assets/Ooredoo.png',
                                    height: 30,
                                  ),
                                if (helper.ticketWon == Ops.orange)
                                  Image.asset(
                                    'assets/orange.png',
                                    height: 30,
                                  ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                snapshot.data.docs[0].data()['value'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Clipboard.setData(
                                  ClipboardData(
                                      text: snapshot.data.docs[0]
                                          .data()['value']),
                                );
                                Fluttertoast.showToast(
                                  msg: "Copied to clipboard",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 16.0,
                                );
                                if (!_rewardedAd.isLoaded) {
                                  await _rewardedAd.load();
                                } else if (_rewardedAd.isLoaded) {
                                  _rewardedAd
                                      .show()
                                      .then((value) => _rewardedAd.load());
                                }
                              },
                              child: const Text(
                                'Copy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    } else if (snapshot.hasError) {
                      return const Text("erorr");
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

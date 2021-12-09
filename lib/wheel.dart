import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spinandwin/ad_state.dart';
import 'package:spinandwin/dialog.dart';
import 'package:spinandwin/helper.dart';

class Wheel extends StatefulWidget {
  const Wheel({
    Key? key,
  }) : super(key: key);

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  bool reward = false;
  RewardedAd rewardedAd = RewardedAd(unitId: AdState().rewardedAdUnitId);
  InterstitialAd interstitialAd =
      InterstitialAd(unitId: AdState().finishSpinAdUnitId);

  dialog(Helper helper) {
    var ticket = helper.fetchTicket();

    showDialog(
      context: context,
      builder: (_) {
        return WinDialog(context: context, ticket: ticket);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    rewardedAd.load();
    interstitialAd.load();
    rewardedAd.onEvent.listen((event) {
      if (event.keys.first == RewardedAdEvent.earnedReward) {
        reward = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Helper helper = Provider.of<Helper>(context);
    if (helper.isReady) {
      var items = helper.items;
      return GestureDetector(
        onTap: () async {
          if (!rewardedAd.isLoaded) {
            await rewardedAd.load();
          } else if (rewardedAd.isLoaded) {
            rewardedAd.show().then((value) => setState(() {
                  if (reward == true) {
                    helper.play();
                    reward = false;
                  }
                  rewardedAd.load();
                }));
          }
        },
        child: FortuneWheel(
          indicators: [
            FortuneIndicator(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/spin_arrow.png',
                width: 60,
              ),
            ),
          ],
          onFling: () async {
            if (!rewardedAd.isLoaded) {
              await rewardedAd.load();
            } else if (rewardedAd.isLoaded) {
              rewardedAd.show().then((value) => setState(() {
                    if (reward == true) {
                      helper.play();
                      reward = false;
                    }
                    rewardedAd.load();
                  }));
            }
          },
          animateFirst: false,
          onAnimationEnd: () async {
            if (!interstitialAd.isLoaded) {
              await interstitialAd.load();
            } else if (interstitialAd.isLoaded) {
              interstitialAd.show().then((value) => interstitialAd.load());
            }
            helper.update();
            if (helper.winner) {
              dialog(helper);
            }
          },
          selected: helper.selected.stream,
          items: [
            for (var it in items) it.build(),
          ],
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}

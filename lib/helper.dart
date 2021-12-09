import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

enum Ops { tt, orange, ooredoo, none, minus, plus }

var minusColor = Colors.red;
var plusColor = Colors.greenAccent.shade700;

class Helper extends ChangeNotifier {
  int coins = 0;
  Ops ticketWon = Ops.none;
  CollectionReference tt = FirebaseFirestore.instance.collection('tt');
  CollectionReference orange = FirebaseFirestore.instance.collection('orange');
  CollectionReference ooredoo =
      FirebaseFirestore.instance.collection('ooredoor');
  CollectionReference chances =
      FirebaseFirestore.instance.collection('chances');
  StreamController<int> selected = StreamController<int>.broadcast();

  var ttChances = 0;
  var ooredooChances = 0;
  var orangeChances = 0;
  var iphoneChances = 0;
  var defaultChances = 1;

  late List<WheelItem> _items;
  bool _isReady = false;
  bool _winner = false;

  Helper() {
    getChances();
  }

  get items => _items;
  get winner => _winner;
  get isReady => _isReady;

  randomByChance() {
    var expanded = _items
        .expand(
          (_item) => List.filled(
            _item.chance,
            _item.index,
          ),
        )
        .toList();
    var index = expanded[Random().nextInt(expanded.length)];
    return index;
  }

  didWin(index) {
    for (var item in items) {
      if (item.index == index) {
        if (item.win == true) {
          ticketWon = item.ops;
          return true;
        } else if (item.value != 0) {
          if (item.ops == Ops.minus) {
            coins -= item.value as int;
          } else {
            coins += item.value as int;
          }
          if (coins < 0) {
            coins = 0;
          }
        }
      }
    }
    return false;
  }

  fetchTicket() async {
    Future<QuerySnapshot<Object?>> data;
    if (ticketWon == Ops.tt) {
      data = tt.get();
      tt.get().then((data) {
        if (data.docs.isNotEmpty) {
          tt.doc(data.docs[0].id).delete();
        }
      });
      return data;
    } else if (ticketWon == Ops.orange) {
      data = orange.get();
      orange.get().then((data) {
        if (data.docs.isNotEmpty) {
          orange.doc(data.docs[0].id).delete();
        }
      });
      return data;
    } else if (ticketWon == Ops.ooredoo) {
      data = ooredoo.get();
      ooredoo.get().then((data) {
        if (data.docs.isNotEmpty) {
          ooredoo.doc(data.docs[0].id).delete();
        }
      });
      return data;
    }
  }

  update() {
    notifyListeners();
  }

  getChances() {
    // ignore: prefer_typing_uninitialized_variables
    var dat;
    chances.get().then((data) {
      dat = data.docs[0].data();
      ttChances = dat['tt'];
      orangeChances = dat['orange'];
      ooredooChances = dat['ooredoo'];
      defaultChances = dat['default'];
      iphoneChances = dat['ihpone'];
    }).whenComplete(() {
      _items = <WheelItem>[
        WheelItem(
          chance: iphoneChances,
          color: const Color(0xFF343399),
          text: 'iPhone 13',
          image: 'assets/iphone13.png',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFF3d3dd1),
          text: '- 100',
          value: 100,
          ops: Ops.minus,
          textColor: minusColor,
          image: 'assets/Coin.png',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFF336799),
          text: 'Good luck!',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFF0198cd),
          text: '- 10',
          value: 10,
          ops: Ops.minus,
          image: 'assets/Coin.png',
          textColor: minusColor,
        ),
        WheelItem(
          chance: orangeChances,
          color: const Color(0xFF009a66),
          win: true,
          text: '1 DT',
          ops: Ops.orange,
          image: 'assets/orange.png',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFF9acd34),
          text: '- 5',
          value: 5,
          ops: Ops.minus,
          textColor: minusColor,
          image: 'assets/Coin.png',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFFcdcd9b),
          text: 'next time!',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFFf0d507),
          text: '+ 5',
          value: 5,
          ops: Ops.plus,
          image: 'assets/Coin.png',
          textColor: plusColor,
        ),
        WheelItem(
          chance: ttChances,
          win: true,
          color: const Color(0xFFff9900),
          text: '50 \$',
          ops: Ops.tt,
          image: 'assets/amazon.png',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFFff6632),
          text: '+ 10',
          value: 10,
          ops: Ops.plus,
          textColor: plusColor,
          image: 'assets/Coin.png',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFFff3334),
          text: 'hmm!',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFFcd0067),
          text: '+ 1',
          value: 1,
          ops: Ops.plus,
          textColor: plusColor,
          image: 'assets/Coin.png',
        ),
        WheelItem(
          chance: ooredooChances,
          win: true,
          color: const Color(0xFFcd6799),
          text: '1 DT',
          ops: Ops.ooredoo,
          image: 'assets/Ooredoo.png',
        ),
        WheelItem(
          chance: defaultChances,
          color: const Color(0xFF673398),
          text: '- 1',
          value: 1,
          textColor: minusColor,
          ops: Ops.minus,
          image: 'assets/Coin.png',
        ),
      ];
      _isReady = true;
      notifyListeners();
    });
  }

  play() {
    var choice = randomByChance();
    selected.add(choice);
    if (didWin(choice)) {
      _winner = true;
    } else {
      _winner = false;
    }
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }
}

class WheelItem {
  static int counter = 0;
  late int index;
  int chance;
  bool win;
  String text;
  Color color;
  String? image;
  Ops ops;
  int value;
  Color textColor;

  WheelItem({
    this.chance = 0,
    this.win = false,
    this.text = '',
    this.color = Colors.green,
    this.image,
    this.ops = Ops.none,
    this.value = 0,
    this.textColor = Colors.white,
  }) {
    index = counter;
    counter++;
  }

  FortuneItem build() {
    return FortuneItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          if (image != null)
            Image.asset(
              image!,
              width: 40,
            ),
        ],
      ),
      style: FortuneItemStyle(
          color: color, borderWidth: 1, borderColor: Colors.amber),
    );
  }
}

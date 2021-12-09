import 'dart:math';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:pimp_my_button/pimp_my_button.dart';

class Particles extends Particle {
  @override
  void paint(Canvas canvas, Size size, progress, seed) {
    Random random = Random(seed);
    int randomMirrorOffset = random.nextInt(16) + 1;
    CompositeParticle(children: [
      Firework(),
      CircleMirror(
          numberOfParticles: 6,
          child: AnimatedPositionedParticle(
            begin: const Offset(0.0, 20.0),
            end: const Offset(0.0, 500.0),
            child: FadingRect(width: 5.0, height: 15.0, color: Colors.pink),
          ),
          initialRotation: -pi / randomMirrorOffset),
      CircleMirror.builder(
          numberOfParticles: 10,
          particleBuilder: (index) {
            return IntervalParticle(
                child: AnimatedPositionedParticle(
                  begin: const Offset(0.0, 20.0),
                  end: const Offset(0.0, 500.0),
                  child: FadingTriangle(
                      baseSize: 6.0 + random.nextDouble() * 4.0,
                      heightToBaseFactor: 1.0 + random.nextDouble(),
                      variation: random.nextDouble(),
                      color: Colors.green),
                ),
                interval: const Interval(
                  0.0,
                  0.8,
                ));
          },
          initialRotation: -pi / randomMirrorOffset + 8),
    ]).paint(canvas, size, progress, seed);
  }
}

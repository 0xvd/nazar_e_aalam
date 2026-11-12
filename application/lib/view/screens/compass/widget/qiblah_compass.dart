// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

// import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({super.key});

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  double _deviceTurns = 0;
  double _qiblahTurns = 0;
  double _previousDevice = 0;
  double _previousQiblah = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const QuiblaeShimmerScreen();
        }

        final qiblahDirection = snapshot.data!;
        final deviceAngle = qiblahDirection.direction;
        final qiblahAngle = qiblahDirection.qiblah;

        // Accumulate turns along the shortest arc
        _deviceTurns += _shortestTurn(deviceAngle, _previousDevice);
        _qiblahTurns += _shortestTurn(qiblahAngle, _previousQiblah);
        _previousDevice = deviceAngle;
        _previousQiblah = qiblahAngle;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass background
                    AnimatedRotation(
                      turns: -_deviceTurns,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear,
                      child: Image.asset(
                        Images.Compass,
                        height: 330,
                        fit: BoxFit.fill,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    // Needle
                    AnimatedRotation(
                      turns: -_qiblahTurns,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.linear,
                      child: Image.asset(
                        Images.Compass_Needle,
                        height: 400,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).hintColor.withOpacity(0.05),
                      Theme.of(context).hintColor.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${((qiblahDirection.direction - 285) % 360).toInt()}°",
                      // "${(qiblahDirection.offset.toInt())}°",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'device_angle_to_qibla'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        );
      },
    );
  }

  double _shortestTurn(double current, double previous) {
    double diff = current - previous;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff / 360;
  }

}
// class QiblahCompassWidget extends StatefulWidget {
//   const QiblahCompassWidget({super.key});
//
//   @override
//   State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
// }
//
// class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
//   double _previousDirection = 0;
//   double _previousQiblah = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FlutterQiblah.qiblahStream,
//       builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
//         if (!snapshot.hasData) {
//           return const QuiblaeShimmerScreen();
//         }
//
//         final qiblahDirection = snapshot.data!;
//         double newDirection = qiblahDirection.direction;
//         double newQiblah = qiblahDirection.qiblah;
//
//         // Normalize angles to prevent sudden jumps
//         newDirection = _normalizeAngle(newDirection, _previousDirection);
//         newQiblah = _normalizeAngle(newQiblah, _previousQiblah);
//
//         _previousDirection = newDirection;
//         _previousQiblah = newQiblah;
//
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//              const SizedBox(height: 20.0),
//             Expanded(
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: <Widget>[
//                   TweenAnimationBuilder<double>(
//                     tween: Tween<double>(
//                         begin: _previousDirection, end: newDirection),
//                     duration: const Duration(milliseconds: 700),
//                     curve: Curves.easeOutExpo,
//                     builder: (context, angle, child) {
//                       return Transform.rotate(
//                         angle: -angle * (pi / 180),
//                         child: child,
//                       );
//                     },
//                     child: Image.asset(
//                       Images.Compass,
//                       height: 330,
//                       fit: BoxFit.fill,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   TweenAnimationBuilder<double>(
//                     tween:
//                     Tween<double>(begin: _previousQiblah, end: newQiblah),
//                     duration: const Duration(milliseconds: 1000),
//                     curve: Curves.easeOutExpo,
//                     builder: (context, angle, child) {
//                       return Transform.rotate(
//                         angle: -angle * (pi / 180),
//                         child: child,
//                       );
//                     },
//                     child: Image.asset(
//                       Images.Compass_Needle,
//                       height: 400,
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Theme.of(context).hintColor.withOpacity(0.05),
//                     Theme.of(context).hintColor.withOpacity(0.10),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(18.0),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.max,
//                 children: <Widget>[
//                   Text(
//                     "${((qiblahDirection.direction - 285) % 360).toInt()}°",
//                     style: robotoMedium.copyWith(
//                       fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 2.0),
//                   Text('device_angle_to_qibla'.tr,
//                       style: robotoMedium.copyWith(
//                         fontSize: Dimensions.FONT_SIZE_DEFAULT,
//                       )),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 40.0),
//           ],
//         );
//       },
//     );
//   }
//
//   double _normalizeAngle(double current, double previous) {
//     double diff = current - previous;
//     if (diff.abs() > 180) {
//       if (diff > 0) {
//         current -= 360;
//       } else {
//         current += 360;
//       }
//     }
//     return current;
//   }
// }

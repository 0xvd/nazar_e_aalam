import 'package:flutter/material.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class HaramFoodContaint extends StatelessWidget {
  final String title;
  final String containt;
  const HaramFoodContaint(
      {super.key, required this.title, required this.containt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 5),

        // title ===>
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.FONT_SIZE_LARGE,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 5),

        // containt ===>
        Text(
          containt,
          textAlign: TextAlign.justify,
          style: robotoMedium.copyWith(
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

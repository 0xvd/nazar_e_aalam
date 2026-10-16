// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class LocationErrorWidget extends StatelessWidget {
  final String? error;

  const LocationErrorWidget({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    const box = SizedBox(height: 32);

    // if loacton error then show this page
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.location_off_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.error,
          ),
          box,
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold),
            ),
          ),
          box,
        ],
      ),
    );
  }
}

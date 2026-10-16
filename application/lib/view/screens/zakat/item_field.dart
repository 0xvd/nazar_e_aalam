import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class ItemField extends StatelessWidget {
  final String fieldName;
  final TextEditingController controllerValue;

  const ItemField(
      {required this.fieldName, required this.controllerValue, super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            fieldName,
            style:
                robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
          ),
        ),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: controllerValue,
            decoration: InputDecoration(
              hintText: "amount".tr,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w400,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 177, 33, 5), width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

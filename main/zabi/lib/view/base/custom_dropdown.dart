// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class CustomDropDown extends StatefulWidget {
  final String? dwValue;
  final double? height;
  final List<Map<String, String>> dwItems;
  final Function(dynamic value) onChange;
  final double? width;
  final String? hintText;
  final Color? textColor;
  final Color? borderColor;
  final Color? bgColor;
  final Color? itemColor;
  final TextStyle? titleTextStyle;
  final bool isFillColor;
  final bool isBorder;
  final String? title;
  final bool isRequired;

  const CustomDropDown({
    super.key,
    required this.dwItems,
    required this.dwValue,
    required this.onChange,
    this.width,
    this.bgColor,
    this.borderColor,
    this.hintText,
    this.textColor,
    this.itemColor,
    this.titleTextStyle,
    this.isFillColor = false,
    this.isBorder = true,
    this.isRequired = true,
    this.title,
    this.height,
  });

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        if (widget.title != null)
          Row(
            children: [
              Text(
                widget.title!,
                style: widget.titleTextStyle ??
                    robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontSize: Dimensions.FONT_SIZE_DEFAULT,
                    ),
              ),
              if (widget.isRequired)
                Text(
                  " *",
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.FONT_SIZE_LARGE),
                ),
            ],
          ),
        SizedBox(
            height: widget.title != null ? Dimensions.PADDING_SIZE_SMALL : 0),

        // Text Field Section
        SizedBox(
          height: widget.height ?? 50,
          child: ButtonTheme(
            alignedDropdown: true,
            padding: EdgeInsets.zero,
            child: Container(
              color: widget.bgColor ??
                  Theme.of(context).highlightColor.withOpacity(0.1),
              child: DropdownButtonFormField<String>(
                dropdownColor: Theme.of(context).cardColor,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0, vertical: Dimensions.PADDING_SIZE_DEFAULT),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(.7),
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(.7),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                ),
                hint: Text(
                  widget.hintText ?? '',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                    color: Theme.of(context).disabledColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(
                      right: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                isExpanded: true,
                isDense: true,
                value: widget.dwValue,
                onChanged: (newValue) {
                  setState(() {
                    widget.onChange(newValue);
                  });
                },
                items: widget.dwItems
                    .map(
                      (Map<String, String> item) => DropdownMenuItem<String>(
                        value: item['id'],
                        child: Text(
                          "${item['value']}".tr,
                          textAlign: TextAlign.start,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

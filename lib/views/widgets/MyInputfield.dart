// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:manager/theme.dart';

class MyInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  final bool readOnly;
  final bool enabled;
  const MyInputField(
      {Key? key,
      required this.title,
      required this.hint,
      this.controller,
      this.readOnly = false,
      this.enabled = true,
      this.widget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:addStyle,
          ),
          Container(
            height: 52,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                )),
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                      enabled:enabled ,
                  
                  readOnly : readOnly,
                  autofocus: false,
                  cursorColor: royalBlue,
                  controller: controller,
                  decoration:
                      InputDecoration(hintText: hint, border: InputBorder.none , fillColor: Colors.white),
                )),
                widget == null
                    ? Container()
                    : Container(
                        child: widget,
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}

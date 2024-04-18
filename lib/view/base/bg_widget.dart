import 'package:flutter/material.dart';

class BgWidget extends StatelessWidget {
  final Widget child;
  const BgWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [

      Container(
        color: Theme.of(context).cardColor,
      ),

      child,

    ]);
  }
}

import 'package:flutter/material.dart';

class DialogAvoidBottom extends Dialog {
  final Widget content;

  DialogAvoidBottom({Key? key, required this.content});

  @override
  Widget build(BuildContext context) {
   return Material(
     type:MaterialType.transparency,
     child: Scaffold(
       backgroundColor:Colors.transparent,
       resizeToAvoidBottomInset: false,
       body: content ,
     ),
   );
  }
}
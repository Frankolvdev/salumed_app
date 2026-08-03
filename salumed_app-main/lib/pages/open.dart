import 'package:flutter/material.dart';

class Open extends StatefulWidget {
  const Open({Key? key}) : super(key: key);

  @override
  State<Open> createState() => _OpenState();
}

class _OpenState extends State<Open> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      print("arguments");
      print(args);
    });
  }

  checkRoute() {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("open"),
    );
  }
}

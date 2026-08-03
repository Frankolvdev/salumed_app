import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/models/asset.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PreviewAssetImage extends StatefulWidget {
  String image;
  int index = 0;
  PreviewAssetImage(this.image, {Key? key}) : super(key: key);

  @override
  _PreviewAssetImageState createState() => _PreviewAssetImageState();
}

class _PreviewAssetImageState extends State<PreviewAssetImage> {
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              )),
          elevation: 0,
          centerTitle: true,
          leading: new IconButton(
            icon: new FaIcon(FontAwesomeIcons.arrowLeft,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: Container(
          child: PhotoView(
        imageProvider: AssetImage("assets/images/${widget.image}"),
      )),
    );
  }
}


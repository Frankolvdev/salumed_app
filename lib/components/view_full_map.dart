import 'package:app/components/map_location.dart';
import 'package:app/constants/colors.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewFullMap extends StatefulWidget {
  PharmacyModel pharmacy;
  ViewFullMap(this.pharmacy, {Key? key}) : super(key: key);

  @override
  State<ViewFullMap> createState() => _ViewFullMapState();
}

class _ViewFullMapState extends State<ViewFullMap> {
  GlobalKey<dynamic> mapState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        backgroundColor: Colors.transparent,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(""),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: FaIcon(FontAwesomeIcons.arrowLeft,
                    size: 20, color: CustomColors.primary),
              ))),
      body: MapLocation(widget.pharmacy.place!, widget.pharmacy.title ?? "",
          key: mapState, showFull: true),
    );
  }
}


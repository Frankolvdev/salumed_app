import 'package:app/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryQuestionnaire extends StatefulWidget {
  Widget catQuestionnaire;
  CategoryQuestionnaire(this.catQuestionnaire, {Key? key}) : super(key: key);

  @override
  _CategoryQuestionnaireState createState() => _CategoryQuestionnaireState();
}

class _CategoryQuestionnaireState extends State<CategoryQuestionnaire> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("",
                style: TextStyle(
                  color: CustomColors.primary,
                  fontSize: 20.0,
                )),
            elevation: 0,
            centerTitle: true,
            leading: new IconButton(
              icon: new FaIcon(FontAwesomeIcons.arrowLeft,
                size: 20,
                color: CustomColors.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: Center(
          child: Container(
              constraints:
                  kIsWeb ? BoxConstraints(maxWidth: 600) : BoxConstraints(),
              child: widget.catQuestionnaire),
        ));
  }
}


import 'dart:async';

import 'package:app/helpers/helpers.dart';
import 'package:app/models/suggestion.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPlacesStream {
  var _searchPlacesControllerWhere = new StreamController.broadcast();

  SearchPlacesStream() {}

  Stream<dynamic> get searchPlacesStreamWhere =>
      _searchPlacesControllerWhere.stream;

  void searchPlacesByKeywordWhere(
      String keyword, BuildContext context, String lang) {
    if (keyword.isNotEmpty) {
      _searchPlacesControllerWhere.sink.add("searching");
      if (!kIsWeb) {
        WebService(context).getSuggestions(keyword, lang).then((value) {
          _searchPlacesControllerWhere.sink.add(value);
        }).catchError((e) {
          print(e);
        });
      } else {
        final provider = Provider.of<AppProvider>(context, listen: false);
        WebService(context)
            .getSuggestionsWeb(keyword, lang, provider.user.token ?? "")
            .then((value) {
          _searchPlacesControllerWhere.sink.add(value);
        }).catchError((e) {
          print(e);
        });
      }
    } else {
      _searchPlacesControllerWhere.add(null);
    }
  }
}

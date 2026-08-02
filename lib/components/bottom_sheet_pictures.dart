import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:universal_io/io.dart';

class BottomSheetPictures {
  BuildContext context;
  int index = 0;
  int indexImage = 0;
  List<dynamic> pictures;

  PageController _pageController = PageController(initialPage: 0);
  BottomSheetPictures(this.context, this.index, this.pictures);

  showBottomSheetPictures() {
    _pageController = PageController(initialPage: index);
    indexImage = index;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext contextB, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .90,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(150.0, 20.9, 150.0, 0.0),
                        child: Container(
                          height: 8.0,
                          width: 80.0,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(8.0))),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              _pageController.previousPage(
                                  duration: Duration(microseconds: 500),
                                  curve: Curves.bounceIn);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.keyboard_arrow_left,
                                size: 38,
                                color: CustomColors.primary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _pageController.nextPage(
                                  duration: Duration(microseconds: 500),
                                  curve: Curves.bounceIn);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.keyboard_arrow_right,
                                size: 38,
                                color: CustomColors.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${indexImage + 1}/${pictures.length}",
                              style: TextStyle(color: Colors.black),
                            )),
                      ),
                      Expanded(
                        child: PhotoViewGallery.builder(
                          backgroundDecoration:
                              BoxDecoration(color: Colors.transparent),
                          itemCount: pictures.length,
                          scrollPhysics: const BouncingScrollPhysics(),
                          builder: (BuildContext context, int i) {
                            if (pictures[i] is AssetModel) {
                              return PhotoViewGalleryPageOptions(
                                minScale:
                                    PhotoViewComputedScale.contained * 0.5,
                                maxScale:
                                    PhotoViewComputedScale.contained * 1.5,
                                imageProvider: NetworkImage(
                                    getImageUrl(pictures[indexImage])),
                                initialScale:
                                    PhotoViewComputedScale.contained * 0.9,
                                heroAttributes: PhotoViewHeroAttributes(tag: i),
                              );
                            } else if (pictures[i] is File) {
                              return PhotoViewGalleryPageOptions(
                                minScale:
                                    PhotoViewComputedScale.contained * 0.5,
                                maxScale:
                                    PhotoViewComputedScale.contained * 1.5,
                                imageProvider: FileImage(pictures[indexImage]),
                                initialScale:
                                    PhotoViewComputedScale.contained * 0.9,
                                heroAttributes: PhotoViewHeroAttributes(tag: i),
                              );
                            } else {
                              return PhotoViewGalleryPageOptions(
                                minScale:
                                    PhotoViewComputedScale.contained * 0.5,
                                maxScale:
                                    PhotoViewComputedScale.contained * 1.5,
                                imageProvider:
                                    MemoryImage(pictures[indexImage]),
                                initialScale:
                                    PhotoViewComputedScale.contained * 0.9,
                                heroAttributes: PhotoViewHeroAttributes(tag: i),
                              );
                            }
                          },

                          loadingBuilder: (context, event) => Center(
                              child: Container(
                            width: 20,
                            height: 20,
                            color: Colors.transparent,
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    CustomColors.primary)),
                          )),
                          //backgroundDecoration: widget.backgroundDecoration,
                          pageController: _pageController,
                          onPageChanged: (int i) {
                            setState(() {
                              indexImage = i;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          });
        });
  }
}

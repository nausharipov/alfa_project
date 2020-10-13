import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:alfa_project/components/icons/custom_icons.dart';
import 'package:alfa_project/components/styles/app_style.dart';
import 'package:alfa_project/components/widgets/bounce_button.dart';
import 'package:alfa_project/core/data/consts/app_const.dart';
import 'package:alfa_project/core/data/models/dialog_type.dart';
import 'package:alfa_project/provider/story_bloc.dart';
import 'package:alfa_project/screens/search/search_image_text.dart';
import 'package:alfa_project/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class CreateEditFilterTemplateScreen extends StatefulWidget {
  final String templateImageId;
  final File filteredImage;

  CreateEditFilterTemplateScreen({
    this.templateImageId,
    this.filteredImage,
  });

  @override
  _CreateEditFilterTemplateScreenState createState() =>
      _CreateEditFilterTemplateScreenState();
}

class _CreateEditFilterTemplateScreenState
    extends State<CreateEditFilterTemplateScreen> {
  _goBack() {
    final storyBloc = Provider.of<StoryBloc>(context, listen: false);
    storyBloc.setClearStoryData();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final storyBloc = Provider.of<StoryBloc>(context, listen: true);

    return WillPopScope(
      onWillPop: () async => displayCustomDialog(
          context,
          "Вы точно хотите покинуть эту страницу?\n",
          DialogType.AlertDialog,
          true,
          _goBack),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Stack(
            children: [
              RepaintBoundary(
                key: globalKey,
                child: Container(
                  color: Color.fromRGBO(237, 237, 237, 1),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MatrixGestureDetector(
                        shouldRotate: !storyBloc.getImagePositionState,
                        shouldScale: !storyBloc.getImagePositionState,
                        shouldTranslate: !storyBloc.getImagePositionState,
                        onMatrixUpdate: (m, tm, sm, rm) {
                          storyBloc.notifierPicture.value = m;
                        },
                        child: !storyBloc.getImagePositionState
                            ? AnimatedBuilder(
                                animation: storyBloc.notifierPicture,
                                builder: (ctx, child) {
                                  return Transform(
                                    transform: storyBloc.notifierPicture.value,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        Image(
                                            image: FileImage(
                                                widget.filteredImage)),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : StreamBuilder(
                                stream: storyBloc.getPosition,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  return Transform(
                                    transform: storyBloc.getCurrenImagePosition,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        Image(
                                          image:
                                              FileImage(widget.filteredImage),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: CachedNetworkImage(
                          imageUrl: BASE_URL_IMAGE + widget.templateImageId,
                          imageBuilder: (context, imageProvider) => InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => {},
                            child: Container(
                              width: 500,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Center(
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      storyBloc.getTextEnabled
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 50, right: 50, top: 100, bottom: 100),
                              child: Stack(
                                children: [
                                  MatrixGestureDetector(
                                    onMatrixUpdate: (m, tm, sm, rm) {
                                      storyBloc.notifierText.value = m;
                                    },
                                    child: AnimatedBuilder(
                                      animation: storyBloc.notifierText,
                                      builder: (ctx, child) {
                                        return Transform(
                                          transform:
                                              storyBloc.notifierText.value,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 150,
                                                left: 50,
                                                right: 50,
                                                child: Container(
                                                  color: Colors.orange,
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          storyBloc
                                                              .getTextAlignment,
                                                      children: [
                                                        TextField(
                                                          cursorRadius:
                                                              Radius.circular(
                                                                  3),
                                                          maxLines: 1,
                                                          textAlign: storyBloc
                                                              .getAlign,
                                                          autocorrect: false,
                                                          enableSuggestions:
                                                              false,
                                                          style: TextStyle(
                                                            color: storyBloc
                                                                .getTextColor,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            fontSize: 22,
                                                          ),
                                                          cursorColor:
                                                              AppStyle.colorRed,
                                                          decoration:
                                                              InputDecoration(
                                                            fillColor:
                                                                Colors.blue,
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                'Первая поля',
                                                            helperStyle:
                                                                TextStyle(
                                                              color: storyBloc
                                                                  .getTextColor
                                                                  .withOpacity(
                                                                      0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        TextField(
                                                          cursorRadius:
                                                              Radius.circular(
                                                                  3),
                                                          textAlign: storyBloc
                                                              .getAlign,
                                                          maxLines: null,
                                                          style: TextStyle(
                                                            color: storyBloc
                                                                .getTextColor,
                                                            fontSize: 22,
                                                          ),
                                                          cursorColor:
                                                              AppStyle.colorRed,
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                'Второя поля',
                                                            helperStyle:
                                                                TextStyle(
                                                              color: storyBloc
                                                                  .getTextColor
                                                                  .withOpacity(
                                                                      0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) =>
                          ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: storyBloc.getTextEnabled
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: BounceButton(
                                    isShadow: true,
                                    onPressed: () {},
                                    iconImagePath: SvgIconsClass.libraryIcon,
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    'База\nтекстов',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: BounceButton(
                                    isShadow: true,
                                    onPressed: () {
                                      storyBloc.setTextEnabled(
                                          storyBloc.getTextEnabled
                                              ? false
                                              : true);
                                    },
                                    iconImagePath: SvgIconsClass.textSelectIcon,
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    'Размер\nшрифта',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: BounceButton(
                                    isShadow: true,
                                    onPressed: () {
                                      storyBloc.setTextAlign();
                                    },
                                    iconImagePath: SvgIconsClass.textAlignIcon,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: Text(
                                    'Вырав\nнивание',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: BounceButton(
                                    isShadow: true,
                                    onPressed: () {
                                      storyBloc.setTextColor();
                                    },
                                    iconImagePath: SvgIconsClass.fillColorIcon,
                                  ),
                                ),
                                Text(
                                  'Цвет\nшрифта',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppStyle.colorDark,
                                    fontWeight: FontWeight.w300,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: BounceButton(
                                    isShadow: true,
                                    onPressed: () {},
                                    iconImagePath: SvgIconsClass.boldIcon,
                                  ),
                                ),
                                Text(
                                  'Толщина\nшрифта',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppStyle.colorDark,
                                    fontWeight: FontWeight.w300,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: BounceButton(
                                    isShadow: true,
                                    onPressed: () => displayCustomDialog(
                                        context,
                                        "Вы точно хотите покинуть эту страницу?\n",
                                        DialogType.AlertDialog,
                                        true,
                                        _goBack),
                                    iconImagePath: SvgIconsClass.closeIcon,
                                  ),
                                ),
                                Text(
                                  'Удалить',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    color: AppStyle.colorDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : SizedBox(),
                ),
              ),
              storyBloc.getTextEnabled
                  ? const SizedBox()
                  : storyBloc.getImagePositionState
                      ? Positioned(
                          top: 10,
                          left: 10,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 35,
                                width: 35,
                                child: BounceButton(
                                  isShadow: true,
                                  onPressed: () => displayCustomDialog(
                                      context,
                                      "Вы точно хотите покинуть эту страницу?\n",
                                      DialogType.AlertDialog,
                                      true,
                                      _goBack),
                                  iconImagePath: SvgIconsClass.closeIcon,
                                ),
                              ),
                              const Text(
                                'Закрыть',
                                style: TextStyle(
                                  height: 1.5,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black87,
                                ),
                              )
                            ],
                          ),
                        )
                      : SizedBox(),
              storyBloc.getTextEnabled
                  ? const SizedBox()
                  : !storyBloc.getImagePositionState
                      ? Positioned(
                          top: 10,
                          right: 10,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 35,
                                width: 35,
                                child: BounceButton(
                                  isShadow: true,
                                  onPressed: () {
                                    storyBloc.setClearStoryData();
                                    Navigator.pop(context);
                                  },
                                  iconImagePath: SvgIconsClass.closeIcon,
                                ),
                              ),
                              Text(
                                'Закрыть',
                                style: TextStyle(
                                  height: 1.5,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black87,
                                ),
                              )
                            ],
                          ),
                        )
                      : Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 35,
                                      width: 35,
                                      child: BounceButton(
                                        isShadow: true,
                                        onPressed: () {
                                          storyBloc.setTextEnabled(true);
                                        },
                                        iconImagePath:
                                            SvgIconsClass.textSizeIcon,
                                      ),
                                    ),
                                    Text(
                                      'Текст',
                                      style: TextStyle(
                                        height: 1.1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 35,
                                      width: 35,
                                      child: BounceButton(
                                        isShadow: true,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchPickerScreen(
                                                isText: false,
                                              ),
                                            ),
                                          );
                                        },
                                        iconImagePath:
                                            SvgIconsClass.stickerIcon,
                                      ),
                                    ),
                                    Text(
                                      'Стикеры',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.5,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
              Positioned(
                bottom: 20,
                right: 10,
                child: storyBloc.getImagePositionState
                    ? Column(
                        children: [
                          SizedBox(
                            height: 35,
                            width: 35,
                            child: BounceButton(
                              isShadow: true,
                              onPressed: takeScreen,
                              iconImagePath: SvgIconsClass.saveIcon,
                            ),
                          ),
                          Text(
                            'Сохранить',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: AppStyle.colorDark,
                            ),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 35,
                            width: 35,
                            child: BounceButton(
                              isShadow: true,
                              onPressed: () {
                                storyBloc.setImagePositionState(true);
                              },
                              iconImagePath: SvgIconsClass.doneIcon,
                            ),
                          ),
                          Text(
                            'Готово',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: AppStyle.colorDark,
                            ),
                          )
                        ],
                      ),
              ),
              storyBloc.getImagePositionState
                  ? Positioned(
                      bottom: 20,
                      left: 10,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 35,
                            width: 35,
                            child: BounceButton(
                              isShadow: true,
                              onPressed: () {
                                storyBloc.setUndoState(false);
                              },
                              iconImagePath: SvgIconsClass.undoIcon,
                            ),
                          ),
                          Text(
                            'Вернуть',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: AppStyle.colorDark,
                            ),
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();

    if (boundary.debugNeedsPaint) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng();
    }

    var image = await boundary.toImage(pixelRatio: 3);
    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  takeScreen() async {
    var pngBytes = await _capturePng();
    // var bs64 = base64Encode(pngBytes);
    // print(pngBytes);
    // printWrapped(bs64);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File("$dir/" +
        'AlfaStory' +
        "${DateTime.now().millisecondsSinceEpoch}" +
        ".png");
    await file.writeAsBytes(pngBytes);
    log('${file.path}');

    // final result = await ImageGallerySaver.saveImage(pngBytes);

    // return file.path;
    GallerySaver.saveImage(file.path);
  }
}
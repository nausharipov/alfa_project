import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:alfa_project/components/icons/custom_icons.dart';
import 'package:alfa_project/components/styles/app_style.dart';
import 'package:alfa_project/components/widgets/bounce_button.dart';
import 'package:alfa_project/core/data/consts/app_const.dart';
import 'package:alfa_project/core/data/models/dialog_type.dart';
import 'package:alfa_project/provider/home_bloc.dart';
import 'package:alfa_project/provider/story_bloc.dart';
import 'package:alfa_project/screens/search/picker_image_text.dart';
import 'package:alfa_project/screens/search/search_image_text.dart';
import 'package:alfa_project/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../app.dart';
import 'dart:math' as math;

class CreateEditTemplateScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String text;
  CreateEditTemplateScreen({
    this.imageUrl,
    this.title,
    this.text,
  });

  @override
  _CreateEditTemplateScreenState createState() =>
      _CreateEditTemplateScreenState();
}

class _CreateEditTemplateScreenState extends State<CreateEditTemplateScreen> {
  GlobalKey globalKey = GlobalKey();
  double _value;
  final GlobalKey _textKey = GlobalKey();
  Size textSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _value = MediaQuery.of(context).size.width;
    });
  }

  _goBack() {
    final storyBloc = Provider.of<StoryBloc>(context, listen: false);
    storyBloc.setClearStoryData();
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(pageBuilder: (BuildContext context,
            Animation animation, Animation secondaryAnimation) {
          return MyApp();
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }),
        (Route route) => false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyBloc = Provider.of<StoryBloc>(context);

    return WillPopScope(
      onWillPop: () async => displayCustomDialog(
          context,
          "Вы точно хотите покинуть эту страницу?\n",
          DialogType.AlertDialog,
          true,
          null,
          _goBack),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: !storyBloc.getLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: BounceButton(
                                      isShadow: true,
                                      onPressed: () {
                                        storyBloc.setLoading(true);
                                        storyBloc.setTextEnabled(true);
                                      },
                                      iconImagePath:
                                          SvgIconsClass.textSelectIcon,
                                    ),
                                  ),
                                  const Text(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: BounceButton(
                                      isShadow: true,
                                      onPressed: () {
                                        // storyBloc.setLoading(true);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SearchPickerScreen(
                                              isText: false,
                                            ),
                                          ),
                                        );
                                      },
                                      iconImagePath: SvgIconsClass.stickerIcon,
                                    ),
                                  ),
                                  const Text(
                                    'Стикеры',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: BounceButton(
                                  isShadow: true,
                                  onPressed: _capturePng,
                                  iconImagePath: SvgIconsClass.saveIcon,
                                ),
                              ),
                              const Text(
                                'Сохранить',
                                style: TextStyle(
                                  height: 1.5,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              : GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        key: globalKey,
                        child: Container(
                          color: storyBloc.getBackColor,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              widget.imageUrl != null
                                  ? _buildMainImage()
                                  : const SizedBox(),
                              storyBloc.getTextEnabled
                                  ? _buildTextWidget(storyBloc)
                                  : const SizedBox(),
                              _buildDecoImage(),
                            ],
                          ),
                        ),
                      ),
                      _buildToolBar(storyBloc),
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
                                          onPressed: () => displayCustomDialog(
                                              context,
                                              "Вы точно хотите покинуть эту страницу?\n",
                                              DialogType.AlertDialog,
                                              true,
                                              null,
                                              _goBack),
                                          iconImagePath:
                                              SvgIconsClass.closeIcon,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: BounceButton(
                                                onPressed: () {
                                                  storyBloc
                                                      .setTextEnabled(true);
                                                },
                                                iconImagePath:
                                                    SvgIconsClass.textSizeIcon,
                                              ),
                                            ),
                                            Text(
                                              'Текст',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: BounceButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StickerTextPicker(
                                                        isDecoration: true,
                                                        isTextBase: false,
                                                        title: "",
                                                        text: "",
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
                                                fontSize: 11,
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
                        child: !storyBloc.getTextEnabled
                            ? storyBloc.getImagePositionState
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: BounceButton(
                                          onPressed: _capturePng,
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
                                        height: 40,
                                        width: 40,
                                        child: BounceButton(
                                          onPressed: () {
                                            storyBloc
                                                .setImagePositionState(true);
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
                                  )
                            : storyBloc.getTextPositionSaved
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: BounceButton(
                                          onPressed: _capturePng,
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
                                        height: 40,
                                        width: 40,
                                        child: BounceButton(
                                          onPressed: () {
                                            storyBloc.setTextPosition(true);
                                            FocusScope.of(context).unfocus();
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
                                      onPressed: () {
                                        if (storyBloc
                                                .getChildrenStickers.length >
                                            0)
                                          storyBloc.removeLastWidgetChildren();
                                        else
                                          storyBloc.setUndoImageState(false);
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
                          : const SizedBox(),
                      storyBloc.getTextEnabled
                          ? Positioned(
                              bottom: 20,
                              left: 10,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 35,
                                    width: 35,
                                    child: BounceButton(
                                      onPressed: () {
                                        if (storyBloc
                                                .getChildrenStickers.length >
                                            0) {
                                          storyBloc.removeLastWidgetChildren();
                                        } else {
                                          storyBloc.setUndoTextState(false);
                                          if (storyBloc.getImagePositionState ==
                                              false)
                                            storyBloc.setLoading(false);
                                        }
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
                          : const SizedBox(),
                      storyBloc.getTextEnabled
                          ? storyBloc.getTextPositionSaved
                              ? const SizedBox()
                              : Positioned(
                                  bottom: 80,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ]),
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          thumbShape: RoundSliderThumbShape()),
                                      child: Slider(
                                        value: storyBloc.textWidthContainer,
                                        max: _value * 0.75,
                                        min: 5,
                                        onChanged: (newValue) {
                                          storyBloc
                                              .setTextWidthContainer(newValue);
                                          log('$newValue');
                                        },
                                      ),
                                    ),
                                  ),
                                )
                          : const SizedBox(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildToolBar(StoryBloc storyBloc) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: storyBloc.getTextPositionSaved
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: BounceButton(
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => SearchPickerScreen(
                              //       isText: false,
                              //       isTextToImage: true,
                              //     ),
                              //   ),
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StickerTextPicker(
                                    isDecoration: true,
                                    isTextBase: false,
                                    title: "",
                                    text: "",
                                  ),
                                ),
                              );
                            },
                            iconImagePath: SvgIconsClass.stickerIcon,
                          ),
                        ),
                        Text(
                          'Стикеры',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: BounceButton(
                            onPressed: () => displayCustomDialog(
                                context,
                                "Вы точно хотите покинуть эту страницу?\n",
                                DialogType.AlertDialog,
                                true,
                                null,
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
                  ),
                ],
              )
            : storyBloc.getTextEnabled
                ? storyBloc.getTitle == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 35,
                                width: 35,
                                child: BounceButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SearchPickerScreen(
                                            isText: true,
                                            isTextToImage: true,
                                          ),
                                        ));
                                  },
                                  iconImagePath: SvgIconsClass.libraryIcon,
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  'База',
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
                                  onPressed: () => storyBloc.setFontSize(),
                                  iconImagePath: SvgIconsClass.textSelectIcon,
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  'Размер',
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
                                  onPressed: () {
                                    storyBloc.setTextAlign();
                                  },
                                  iconImagePath: SvgIconsClass.textAlignIcon,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  'Ровнять',
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
                                  onPressed: () {
                                    storyBloc.setTextColor();
                                  },
                                  iconImagePath: SvgIconsClass.fillColorIcon,
                                ),
                              ),
                              Text(
                                'Цвет',
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
                                  onPressed: () =>
                                      storyBloc.setFontCustomWeight(),
                                  iconImagePath: SvgIconsClass.boldIcon,
                                ),
                              ),
                              Text(
                                'Толщина',
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
                                width: 32,
                                child: BounceButton(
                                  onPressed: () => displayCustomDialog(
                                      context,
                                      "Вы точно хотите покинуть эту страницу?\n",
                                      DialogType.AlertDialog,
                                      true,
                                      null,
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 35,
                                width: 35,
                                child: BounceButton(
                                  onPressed: () {
                                    storyBloc.setTextAlign();
                                  },
                                  iconImagePath: SvgIconsClass.textAlignIcon,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  'Ровнять',
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
                                  onPressed: () {
                                    storyBloc.setTextColor();
                                  },
                                  iconImagePath: SvgIconsClass.fillColorIcon,
                                ),
                              ),
                              Text(
                                'Цвет',
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
                                  onPressed: () =>
                                      storyBloc.setTextBaseFontSize(),
                                  iconImagePath: SvgIconsClass.textSizeIcon,
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  'Размер',
                                  style: TextStyle(
                                    color: AppStyle.colorDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 35,
                                    width: 32,
                                    child: BounceButton(
                                      onPressed: () => displayCustomDialog(
                                          context,
                                          "Вы точно хотите покинуть эту страницу?\n",
                                          DialogType.AlertDialog,
                                          true,
                                          null,
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
                            ),
                          ),
                        ],
                      )
                : const SizedBox(),
      ),
    );
  }

  Future<void> _capturePng() {
    final homeBloc = Provider.of<HomeBloc>(context, listen: false);
    final storyBloc = Provider.of<StoryBloc>(context, listen: false);
    // displayCustomDialog(
    //   context,
    //   'null',
    //   DialogType.LoadingDialog,
    //   false,
    //   true,
    //   null,
    // );
    return new Future.delayed(const Duration(milliseconds: 28), () async {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();

      ui.Image image = await boundary.toImage(pixelRatio: 3);

      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File("$dir/" +
          'AlfaStory' +
          "${DateTime.now().millisecondsSinceEpoch}" +
          ".png");

      if (!homeBloc.getIsStoryTemplate) {
        storyBloc.getUiImage(pngBytes, 1920, 1536).then((value) async {
          log("${value.height}");
          log("${value.width}");

          ByteData byteData =
              await value.toByteData(format: ui.ImageByteFormat.png);
          Uint8List pngBytes = byteData.buffer.asUint8List();
          await file.writeAsBytes(pngBytes);

          GallerySaver.saveImage(file.path).then((value) {
            displayCustomDialog(
              context,
              null,
              DialogType.InfoDialog,
              false,
              value,
              _goToInitialHome,
            );
          });
        });
      } else {
        await file.writeAsBytes(pngBytes);
        log('${file.path}');

        GallerySaver.saveImage(file.path).then((value) {
          log("$value");
          displayCustomDialog(
            context,
            null,
            DialogType.InfoDialog,
            false,
            value,
            _goToInitialHome,
          );
        });
      }

      // if (!homeBloc.getIsStoryTemplate) {
      //   // ui.Image x = await decodeImageFromList(pngBytes);
      //   // print('height is ${x.height}'); //height of original image
      //   // print('width is ${x.width}'); //width of oroginal image
      //   ui
      //       .instantiateImageCodec(
      //     pngBytes,
      //     targetHeight: 1920,
      //     targetWidth: 1536,
      //   )
      //       .then((codec) {
      //     codec.getNextFrame().then((frameInfo) async {
      //       String dir = (await getApplicationDocumentsDirectory()).path;
      //       File file = File("$dir/" +
      //           'AlfaStory' +
      //           "${DateTime.now().millisecondsSinceEpoch}" +
      //           ".png");
      //       ui.Image i = frameInfo.image;
      //       // print('image width is ${i.width}'); //height of resized image
      //       // print('image height is ${i.height}'); //width of resized image
      //       ByteData bytes = await i.toByteData();

      //       await file.writeAsBytes(bytes.buffer.asUint32List());
      //       log('${file.path}');
      //       print('resized image size is ${bytes.lengthInBytes}');
      // GallerySaver.saveImage(file.path).then((value) {
      //   log("$value");
      //   displayCustomDialog(
      //     context,
      //     null,
      //     DialogType.InfoDialog,
      //     false,
      //     value,
      //     _goToInitialHome,
      //   );
      // });
      //     });
      //   });
      // } else {
      //   String dir = (await getApplicationDocumentsDirectory()).path;
      //   File file = File("$dir/" +
      //       'AlfaStory' +
      //       "${DateTime.now().millisecondsSinceEpoch}" +
      //       ".png");
      //
      // }
    });
  }

  _goToInitialHome() {
    final storyBloc = Provider.of<StoryBloc>(context, listen: false);
    storyBloc.setClearStoryData();
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(pageBuilder: (BuildContext context,
            Animation animation, Animation secondaryAnimation) {
          return MyApp();
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }),
        (Route route) => false);
  }

  _buildMainImage() {
    final storyBloc = Provider.of<StoryBloc>(context, listen: true);
    return CachedNetworkImage(
      imageUrl: BASE_URL_IMAGE + widget.imageUrl,
      imageBuilder: (context, imageProvider) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: MatrixGestureDetector(
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
                          Image(image: imageProvider),
                        ],
                      ),
                    );
                  },
                )
              : StreamBuilder(
                  stream: storyBloc.getPosition,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return Transform(
                      transform: storyBloc.getCurrenImagePosition,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image(image: imageProvider),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
      placeholder: (context, url) => Center(
        child: !Platform.isAndroid
            ? const CupertinoActivityIndicator(
                radius: 15,
              )
            : SizedBox(
                height: 25,
                width: 25,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: Colors.white,
                ),
              ),
      ),
      errorWidget: (context, url, error) => Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 25,
          ),
          const Text('Проблема с интернетом!\nПроверьте интернет')
        ],
      ),
    );
  }

  getSizeAndPosition() {
    RenderBox _cardBox = _textKey.currentContext.findRenderObject();
    textSize = _cardBox.size;
    setState(() {});
  }

  _buildTextWidget(StoryBloc storyBloc) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return IgnorePointer(
      ignoring: storyBloc.getTextPositionSaved,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double myMaxWidthRight = constraints.maxWidth -
            math.min(storyBloc.textWidthContainer,
                constraints.maxWidth - width * 0.1) -
            width * 0.1;

        double myMaxHeightTop = constraints.maxHeight - height * 0.87; //580
        double myMaxHeightBottom = constraints.maxHeight - height * 0.31; //250
        double myMaxWidthLeft = constraints.maxWidth - width * 0.91; //330

        return Stack(
          children: [
            Positioned(
              left: storyBloc.getOffset.dx,
              top: storyBloc.getOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  Offset offset = Offset(
                      storyBloc.getOffset.dx + details.delta.dx,
                      storyBloc.getOffset.dy + details.delta.dy);

                  storyBloc.setOffsetText(
                    Offset(
                      math.max(
                          math.min(myMaxWidthRight, offset.dx), myMaxWidthLeft),
                      math.max(math.min(myMaxHeightBottom, offset.dy),
                          myMaxHeightTop),
                    ),
                  );
                },
                child: Container(
                  key: _textKey,
                  width: math.min(
                      storyBloc.textWidthContainer, constraints.maxWidth - 80),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: storyBloc.getTextPositionSaved
                          ? Colors.transparent
                          : Color.fromRGBO(200, 203, 208, 1),
                    ),
                  ),
                  child: storyBloc.getTitle == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: storyBloc.getTextAlignment,
                          children: [
                              TextField(
                                cursorRadius: Radius.circular(2),
                                textAlign: storyBloc.getAlign,
                                style: TextStyle(
                                  color: storyBloc.getTextColorFirst,
                                  fontSize: storyBloc.getTitleFontSize,
                                  fontFamily: 'Styrene A LC',
                                  fontWeight:
                                      storyBloc.getCustomTextWeightFirst,
                                ),
                                onTap: () {
                                  storyBloc.setTextFieldEnable(true);
                                },
                                maxLines: null,
                                cursorColor: AppStyle.colorRed,
                                decoration: InputDecoration(
                                  fillColor: Colors.blue,
                                  border: InputBorder.none,
                                  hintText: storyBloc.getTextPositionSaved
                                      ? ''
                                      : 'Напишите что-нибудь...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  helperStyle: TextStyle(
                                    fontSize: 15,
                                    color:
                                        storyBloc.getTextColor.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              TextField(
                                cursorRadius: Radius.circular(2),
                                textAlign: storyBloc.getAlign,
                                onTap: () {
                                  storyBloc.setTextFieldEnable(false);
                                },
                                style: TextStyle(
                                  color: storyBloc.getTextColorSecond,
                                  fontSize: storyBloc.getBodyFontSize,
                                  fontFamily: 'Styrene A LC',
                                  fontWeight:
                                      storyBloc.getCustomTextWeightSecond,
                                ),
                                maxLines: null,
                                cursorColor: AppStyle.colorRed,
                                decoration: InputDecoration(
                                  fillColor: Colors.blue,
                                  border: InputBorder.none,
                                  hintText: storyBloc.getTextPositionSaved
                                      ? ''
                                      : 'Напишите что-нибудь...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  helperStyle: TextStyle(
                                    fontSize: 15,
                                    color:
                                        storyBloc.getTextColor.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ])
                      : Column(
                          crossAxisAlignment: storyBloc.getTextAlignment,
                          children: [
                            Text(
                              storyBloc.getTitle,
                              textAlign: storyBloc.getAlign,
                              style: TextStyle(
                                color: storyBloc.getTextColor,
                                fontSize: storyBloc.getTitleTextBaseFontSize,
                                height: 0.95,
                                fontFamily: 'Styrene A LC',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              storyBloc.getBody,
                              textAlign: storyBloc.getAlign,
                              style: TextStyle(
                                color: storyBloc.getTextColor,
                                fontSize: storyBloc.getBodyTextBaseFontSize,
                                height: 1,
                                fontFamily: 'Styrene A LC',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  _buildDecoImage() {
    final storyBloc = Provider.of<StoryBloc>(context);
    return Stack(
      children: storyBloc.getChildrenStickers,
    );
  }
}

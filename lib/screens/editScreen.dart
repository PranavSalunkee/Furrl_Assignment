import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../module/frameEdit.dart';
import '../module/image.dart';

class EditFrameScreen extends StatefulWidget {
  const EditFrameScreen({Key? key, this.images, this.prevImgPath}) : super(key: key);
  final List<ImageItem>? images;
  final String? prevImgPath;

  @override
  State<EditFrameScreen> createState() => _EditFrameScreenState();
}

class _EditFrameScreenState extends State<EditFrameScreen> {
  late List<ImageItem> imagePositions;
  late List<ImageItem> prevImagePositions;
  final GlobalKey _containerKey = GlobalKey();
  String? imgPath;
  String? prevImgPath;

  @override
  void initState() {
    super.initState();
    imagePositions = widget.images ?? [];
    prevImagePositions = List.from(imagePositions);
    prevImgPath = widget.prevImgPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Frame',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 8,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, EditFrameResult(imagePath: prevImgPath, imageItems: prevImagePositions));
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          Icon(Icons.search),
          SizedBox(width: 10),
          Icon(Icons.bookmark_border_rounded),
          SizedBox(width: 10),
          Icon(Icons.shopping_bag_outlined),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20, child: Container(color: Colors.grey.shade200)),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double maxContainerWidth = constraints.maxWidth;
                double maxContainerHeight = constraints.maxHeight;

                return RepaintBoundary(
                  key: _containerKey,
                  child: DecoratedBox(
                    decoration: BoxDecoration(),
                    child: Container(
                      child: Stack(
                        children: [
                          for (int i = 0; i < imagePositions.length; i++)
                            Positioned(
                              left: imagePositions[i].x,
                              top: imagePositions[i].y,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    final tappedImage = imagePositions.removeAt(i);
                                    imagePositions.add(tappedImage);
                                  });
                                },
                                onDoubleTap: () {
                                  setState(() {
                                    imagePositions.removeAt(i);
                                  });
                                },
                                onScaleStart: (details) {
                                  setState(() {
                                    imagePositions[i].previousScale = imagePositions[i].scale;
                                    imagePositions[i].previousPosition = details.focalPoint;
                                  });
                                },
                                onScaleUpdate: (details) {
                                  setState(() {
                                    double newScale = imagePositions[i].previousScale * details.scale;
                                    newScale = newScale.clamp(ImageItem.minScale, ImageItem.maxScale);

                                    Offset delta = details.focalPoint - imagePositions[i].previousPosition;
                                    double newX = imagePositions[i].x + delta.dx;
                                    double newY = imagePositions[i].y + delta.dy;

                                    double imageWidth = 200 * newScale;
                                    double imageHeight = 200 * newScale;

                                    if (newX < 0) newX = 0;
                                    if (newX + imageWidth > maxContainerWidth) newX = maxContainerWidth - imageWidth;

                                    if (newY < 0) newY = 0;
                                    if (newY + imageHeight > maxContainerHeight) newY = maxContainerHeight - imageHeight;

                                    imagePositions[i].scale = newScale;
                                    imagePositions[i].x = newX;
                                    imagePositions[i].y = newY;
                                    imagePositions[i].previousPosition = details.focalPoint;
                                  });
                                },
                                onScaleEnd: (details) {
                                  setState(() {
                                    imagePositions[i].previousScale = imagePositions[i].scale;
                                    imagePositions[i].previousPosition = Offset(imagePositions[i].x, imagePositions[i].y);
                                  });
                                },
                                child: Transform(
                                  alignment: Alignment.topLeft,
                                  transform: Matrix4.identity()..scale(imagePositions[i].scale),
                                  child: Image.file(
                                    File(imagePositions[i].path),
                                    width: 200,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20, child: Container(color: Colors.grey.shade200)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    child: OutlinedButton(
                      onPressed: () async {
                        XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            imagePositions.add(ImageItem(path: image.path));
                          });
                        }
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.purple),
                          ),
                        ),
                      ),
                      child: Text('Add Image'),
                    ),
                  ),
                  Container(
                    width: 150,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, EditFrameResult(imagePath: prevImgPath, imageItems: prevImagePositions));
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.purple),
                          ),
                        ),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ),
              Container(
                width: 300,
                child: OutlinedButton(
                  onPressed: () async {
                    imgPath = await _captureAndSaveImage();
                    setState(() {
                      imgPath;
                    });

                    Navigator.pop(context, EditFrameResult(imagePath: imgPath, imageItems: imagePositions));
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.purple),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(Color(0xFF7E59E7)),
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> _captureAndSaveImage() async {
    try {
      RenderRepaintBoundary boundary = _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/captured_image_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      print('Error capturing and saving image: $e');
      return '';
    }
  }
}

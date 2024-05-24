import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageItem {
  String path;
  double x;
  double y;
  double scale;
  Offset previousPosition;
  double previousScale;

  static const double minScale = 0.5; // Minimum scale
  static const double maxScale = 1.5; // Maximum scale

  ImageItem({
    required this.path,
    this.x = 0.0,
    this.y = 0.0,
    this.scale = 1.0,
    this.previousPosition = const Offset(0, 0),
    this.previousScale = 1.0,
  });
}

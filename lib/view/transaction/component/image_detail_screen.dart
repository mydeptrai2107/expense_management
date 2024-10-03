import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageDetailScreen extends StatefulWidget {
  final List<String>? imageUrls;
  final List<File>? imageFiles;
  final int initialIndex;

  const ImageDetailScreen({super.key, 
    this.imageUrls,
    this.imageFiles,
    this.initialIndex = 0,
  }) : assert(imageUrls != null || imageFiles != null);

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late List<Object> _allImages;

  @override
  void initState() {
    super.initState();

    List<Object> allImages = [];

    if (widget.imageUrls != null) {
      allImages.addAll(widget.imageUrls!);
    }

    if (widget.imageFiles != null) {
      allImages.addAll(widget.imageFiles!);
    }

    _allImages = allImages;
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1}/${_allImages.length}'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: _allImages.length,
        builder: (context, index) {
          final image = _allImages[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: image is String
                ? NetworkImage(image)
                : FileImage(image as File) as ImageProvider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered,
          );
        },
        pageController: _pageController,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

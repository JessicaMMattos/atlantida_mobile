import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:atlantida_mobile/models/photo.dart';

class FullScreenImageGallery extends StatelessWidget {
  final List<Photo> photos;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final imageData = photo.data;

              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.1,
                maxScale: 5.0,
                child: Center(
                  child: imageData.isEmpty
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey,
                          child: const Icon(Icons.error, color: Colors.red),
                        )
                      : Image.memory(
                          base64Decode(imageData),
                          fit: BoxFit.contain,
                        ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

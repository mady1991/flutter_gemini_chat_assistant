import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../providers/chat_provider.dart';

class PreviewImagesWidget extends StatelessWidget {
  const PreviewImagesWidget({
    super.key,
    this.message,
  });

  final Message? message;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final List<dynamic>? messageToShow =
        message != null ? message!.imagesUrls : chatProvider.imagesFileList;

        if (messageToShow == null || messageToShow.isEmpty) {
          return const SizedBox.shrink();
        }

        final padding = message != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message == null) // Only show title for new images (not in messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Attached Images (${messageToShow.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              Container(
                height: message != null ? 100 : 120, // Larger for new images
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: message != null
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: messageToShow.length,
                  itemBuilder: (context, index) {
                    return _buildImageItem(
                      context,
                      messageToShow[index],
                      index,
                      message != null,
                      chatProvider,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageItem(
      BuildContext context,
      dynamic imageItem,
      int index,
      bool isInMessage,
      ChatProvider chatProvider,
      ) {
    final String imagePath = isInMessage
        ? imageItem as String
        : (imageItem as XFile).path;

    return GestureDetector(
      onTap: () => _showImagePreview(context, imagePath, index, chatProvider),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Stack(
          children: [
            // Main Image
            Container(
              width: isInMessage ? 80 : 100, // Larger for new images
              height: isInMessage ? 80 : 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(imagePath),
              ),
            ),

            // Delete button for new images (not in messages)
            if (!isInMessage)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _deleteImage(context, index, chatProvider),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

            // Image count badge for multiple images
            if (message == null && index == 0 && _getImageCount(chatProvider) > 1)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${_getImageCount(chatProvider) - 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    return FutureBuilder<File>(
      future: _getImageFile(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.error_outline,
              color: Colors.grey[400],
              size: 32,
            ),
          );
        }

        return Image.file(
          snapshot.data!,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Future<File> _getImageFile(String path) async {
    return File(path);
  }

  int _getImageCount(ChatProvider chatProvider) {
    return message != null
        ? message!.imagesUrls.length
        : chatProvider.imagesFileList?.length ?? 0;
  }

  void _showImagePreview(BuildContext context, String imagePath, int currentIndex, ChatProvider chatProvider) {
    final List<String> images = message != null
        ? List<String>.from(message!.imagesUrls)
        : chatProvider.imagesFileList?.map((file) => file.path).toList() ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // Full screen image viewer
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildPreviewImageWidget(images[index]),
                    ),
                  ),
                );
              },
            ),

            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Image counter
            if (images.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentIndex + 1} / ${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Delete button for new images
            if (message == null)
              Positioned(
                bottom: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close preview
                      _deleteImage(context, currentIndex, chatProvider);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImageWidget(String imagePath) {
    return FutureBuilder<File>(
      future: _getImageFile(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Image.file(
          snapshot.data!,
          fit: BoxFit.contain,
        );
      },
    );
  }

  void _deleteImage(BuildContext context, int index, ChatProvider chatProvider) {
    if (message == null) {
      // Show confirmation dialog for deletion
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Remove the image
                final newList = List<XFile>.from(chatProvider.imagesFileList!);
                newList.removeAt(index);
                chatProvider.setImagesFileList(listValue: newList);
                Navigator.of(context).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
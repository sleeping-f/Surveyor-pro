import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  List<File>? _images;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDirectory = Directory(
        p.join(directory.path, 'camera_captures'),
      );

      if (!await imageDirectory.exists()) {
        if (mounted) {
          setState(() {
            _images = [];
            _isLoading = false;
          });
        }
        return;
      }

      final files = imageDirectory
          .listSync(followLinks: false)
          .whereType<File>()
          .where((file) => p.extension(file.path).toLowerCase() == '.jpg')
          .toList();

      // Sort newest first
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      if (mounted) {
        setState(() {
          _images = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _images = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_images == null || _images!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No photos yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Captured photos will appear here.',
              style: AppTextStyles.muted(context),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.sm),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
        ),
        itemCount: _images!.length,
        itemBuilder: (context, index) {
          final file = _images![index];
          return ClipRRect(
            borderRadius: AppSpacing.radius,
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          );
        },
      ),
    );
  }
}


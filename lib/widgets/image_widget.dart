import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ImageFromBackend extends StatefulWidget {
  final String blobName;
  final double? height;
  final BoxFit? fit;

  const ImageFromBackend({
    Key? key,
    required this.blobName,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  State<ImageFromBackend> createState() => _ImageFromBackendState();
}

class _ImageFromBackendState extends State<ImageFromBackend> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ImageFromBackend oldWidget) {
    if (oldWidget.blobName != widget.blobName) {
      _loadImage();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadImage() async {
    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      _isLoading = true;
      _error = null;
      _imageBytes = null;
    });

    final url = '${dotenv.env['BACKEND_URL']}/download/${widget.blobName}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'X-API-Key': dotenv.env['DOWNLOAD_KEY']!},
      );

      if (response.statusCode == 200) {
        if (mounted) { // Check again before setting state
          setState(() {
            _imageBytes = response.bodyBytes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to load image: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading image: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    if (_error != null) {
      return Text(
        _error!,
        style: const TextStyle(color: Colors.red),
      );
    }
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    }
    return const SizedBox.shrink();
  }
}
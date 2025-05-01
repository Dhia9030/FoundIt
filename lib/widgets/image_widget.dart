// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// class ImageFromBackend extends StatefulWidget {
//   final String blobName;
//   final double? height;
//   final BoxFit? fit;
//
//   const ImageFromBackend({Key? key, required this.blobName, this.height, this.fit}) : super(key: key);
//
//   @override
//   State<ImageFromBackend> createState() => _ImageFromBackendState();
// }
//
// class _ImageFromBackendState extends State<ImageFromBackend> {
//   String? _blobUrl;
//   bool _isLoading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadImage();
//   }
//
//   @override
//   void didUpdateWidget(covariant ImageFromBackend oldWidget) {
//     if (oldWidget.blobName != widget.blobName) {
//       _revokeBlobUrl();
//       _loadImage();
//     }
//     super.didUpdateWidget(oldWidget);
//   }
//
//   @override
//   void dispose() {
//     _revokeBlobUrl();
//     super.dispose();
//   }
//
//   void _revokeBlobUrl() {
//     if (_blobUrl != null) {
//       html.Url.revokeObjectUrl(_blobUrl!);
//       _blobUrl = null;
//     }
//   }
//
//   Future<void> _loadImage() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     final url = '${dotenv.env['BACKEND_URL']}/download/${widget.blobName}';
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'X-API-Key': dotenv.env['DOWNLOAD_KEY']!},
//       );
//
//       if (response.statusCode == 200) {
//         final bytes = response.bodyBytes;
//         final blob = html.Blob([bytes], response.headers['content-type']);
//         final imageUrl = html.Url.createObjectUrlFromBlob(blob);
//         setState(() {
//           _blobUrl = imageUrl;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _error = 'Failed to load image: ${response.statusCode}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Error loading image: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const CircularProgressIndicator();
//     }
//     if (_error != null) {
//       return Text(_error!);
//     }
//     if (_blobUrl != null) {
//       return Image.network(_blobUrl!, height: widget.height, fit: widget.fit);
//     }
//     return const SizedBox.shrink(); // Fallback
//   }
// }
//
//
//
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
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load image: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading image: $e';
        _isLoading = false;
      });
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
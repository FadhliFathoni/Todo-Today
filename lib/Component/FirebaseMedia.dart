import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/mainWishList.dart';
import 'package:video_player/video_player.dart';

class FirebaseMedia extends StatefulWidget {
  FirebaseMedia({
    super.key,
    required this.mediaUrl,
    required this.boxFit,
    this.autoPlay = false,
    this.showControls = true,
  });

  final String mediaUrl;
  final BoxFit boxFit;
  final bool autoPlay;
  final bool showControls;

  @override
  State<FirebaseMedia> createState() => _FirebaseMediaState();
}

class _FirebaseMediaState extends State<FirebaseMedia> {
  String baseUrl = 'gs://todo-today-74b74.appspot.com/wishlist/';
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isLoading = true;
  String? _downloadUrl;
  MediaType _mediaType = MediaType.image;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMedia() async {
    try {
      final ref =
          FirebaseStorage.instance.refFromURL(baseUrl + widget.mediaUrl);
      final url = await ref.getDownloadURL();

      setState(() {
        _downloadUrl = url;
        _mediaType = _getMediaType(widget.mediaUrl);
        _isLoading = false;
      });

      if (_mediaType == MediaType.video) {
        _initializeVideo(url);
      }
    } catch (e) {
      setState(() {
        _downloadUrl = widget.mediaUrl; // Fallback to direct URL
        _mediaType = _getMediaType(widget.mediaUrl);
        _isLoading = false;
      });

      if (_mediaType == MediaType.video) {
        _initializeVideo(widget.mediaUrl);
      }
    }
  }

  void _initializeVideo(String url) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        if (widget.autoPlay) {
          _videoController!.play();
        }
      }
    }).catchError((error) {
      print('Error initializing video: $error');
      setState(() {
        _isVideoInitialized = false;
      });
    });
  }

  MediaType _getMediaType(String url) {
    final extension = url.toLowerCase().split('.').last;

    switch (extension) {
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
      case '3gp':
        return MediaType.video;
      case 'gif':
        return MediaType.gif;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'bmp':
      default:
        return MediaType.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: MyCircularProgressIndicator(),
        ),
      );
    }

    if (_downloadUrl == null) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Icon(Icons.error, color: Colors.red),
        ),
      );
    }

    switch (_mediaType) {
      case MediaType.video:
        return _buildVideoPlayer();
      case MediaType.gif:
        return _buildGifImage();
      case MediaType.image:
        return _buildImage();
    }
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: MyCircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        if (widget.showControls) _buildVideoControls(),
      ],
    );
  }

  Widget _buildVideoControls() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
            ),
            Expanded(
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black26,
                ),
              ),
            ),
            Text(
              '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGifImage() {
    return Image.network(
      _downloadUrl!,
      fit: widget.boxFit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.white,
          child: const Center(
            child: MyCircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white,
          child: const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    return Image.network(
      _downloadUrl!,
      fit: widget.boxFit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.white,
          child: const Center(
            child: MyCircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white,
          child: const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

enum MediaType {
  image,
  gif,
  video,
}

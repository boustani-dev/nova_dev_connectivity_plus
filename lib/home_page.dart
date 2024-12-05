import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nova_dev_connectivity_plus/Connection_check.dart';
import 'package:video_player/video_player.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late VideoPlayerController _controller;

  ///Connection check params
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    ///init connection check
    _initializeConnectivity();

    ///init Video player
    _initializeVideoPlayer();
  }

  //init connection check and start listener
  void _initializeConnectivity() {
    // Listen to the connectivity changes
    _connectivitySubscription =
        ConnectionCheck().onConnectivityChanged.listen((_) {
      _checkConnectionStatus();
    });
    // Initial connectivity status check
    _checkConnectionStatus();
  }

//checks and updates the connection status
  Future<void> _checkConnectionStatus() async {
    final result = await ConnectionCheck().getConnectivityStatus();
    setState(() {
      _connectionStatus = result;
    });
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.asset('assets/videos/NIKE.mp4')
      ..addListener(() {
        setState(() {});
      })
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _controller.pause();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product Page",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProductImage(),
            const SizedBox(height: 16),
            _buildProductDetails(),
            const SizedBox(height: 15),
            if (_controller.value.isInitialized) _buildVideoPlayer(),
            const SizedBox(height: 15),
            _buildOrderButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: Image.asset(
        'assets/image/shoes.png',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildProductDetails() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Men Pegasus Trail',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Price: \$29.99',
          style: TextStyle(fontSize: 18, color: Colors.teal),
        ),
        SizedBox(height: 16),
        Text(
          'Product Description:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'The Nike Pegasus Trail 5 is suitable for athletes of all levels. It offers reliability and versatility, making it perfect for both trail and asphalt runs.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.teal,
      ),
      padding: const EdgeInsets.all(15),
      child: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              _buildVideoControls(),
            ],
          ),
          _buildConnectivityBadge(),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
            Text(
              '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              onPressed: () {
                _controller.pause();
                _controller.seekTo(Duration.zero);
              },
            ),
          ],
        ),
        Slider(
          value: _controller.value.position.inSeconds.toDouble(),
          max: _controller.value.duration.inSeconds.toDouble(),
          onChanged: (value) {
            setState(() {
              _controller.seekTo(Duration(seconds: value.toInt()));
            });
          },
        ),
      ],
    );
  }

  Widget _buildConnectivityBadge() {
    String? badgeText;
    Color badgeColor = Colors.transparent;
    if (_connectionStatus.contains(ConnectivityResult.none)) {
      badgeText = 'No Connection';
      badgeColor = Colors.red;
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      badgeText = 'Mobile Data';
      badgeColor = Colors.orange;
    }

    return badgeText != null
        ? Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildOrderButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              if (_connectionStatus.contains(ConnectivityResult.none))
                return AlertDialog(
                  backgroundColor: Colors.red.shade100,
                  title: const Text(
                    'No Internet Connection',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text('Please check your internet connection.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );

              return AlertDialog(
                title: const Text(
                  'Order Confirmation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text('Thank you for your order!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: const Text(
          'Order Now',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}

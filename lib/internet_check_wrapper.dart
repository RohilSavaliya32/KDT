import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'no_internet_screen.dart';

class InternetCheckWrapper extends StatefulWidget {
  final Widget child;

  const InternetCheckWrapper({
    super.key,
    required this.child,
  });

  @override
  State<InternetCheckWrapper> createState() => _InternetCheckWrapperState();
}

class _InternetCheckWrapperState extends State<InternetCheckWrapper> {
  final ValueNotifier<bool> _isConnected = ValueNotifier<bool>(true);
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Delay connectivity check to ensure the initial frame is safe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivity();
      _listenInternetChanges();
    });

    _isConnected.addListener(_handleConnectionChange);
  }

  void _handleConnectionChange() {
    if (!_isConnected.value) {
      _showNoInternetOverlay();
    } else {
      _hideNoInternetOverlay();
    }
  }

  void _showNoInternetOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: NoInternetScreen(
          onRetry: _checkConnectivity,
        ),
      ),
    );

    // Find the overlay and insert
    final overlay = Overlay.of(context, debugRequiredFor: widget);
    overlay.insert(_overlayEntry!);
  }

  void _hideNoInternetOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateStatus(result);
    } catch (e) {
      debugPrint("Connectivity Check Error: $e");
    }
  }

  void _listenInternetChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> result) {
    final hasNet = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    if (_isConnected.value != hasNet) {
      _isConnected.value = hasNet;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _isConnected.removeListener(_handleConnectionChange);
    _isConnected.dispose();
    _hideNoInternetOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ CRITICAL: Return the child (Navigator) directly. 
    // Do NOT wrap it in a Stack or any other layout widget.
    // This prevents the "_elements.contains(element)" crash.
    return widget.child;
  }
}

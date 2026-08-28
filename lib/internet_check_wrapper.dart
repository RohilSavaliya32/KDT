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
  // Use a ValueNotifier to prevent the entire widget tree (Navigator) from rebuilding.
  // We initialize with 'true' to ensure the app starts with the Navigator visible.
  final ValueNotifier<bool> _isConnected = ValueNotifier<bool>(true);
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenInternetChanges();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final hasNet = _hasInternet(result);
      if (_isConnected.value != hasNet) {
        _isConnected.value = hasNet;
      }
    } catch (e) {
      debugPrint("Connectivity Check Error: $e");
    }
  }

  void _listenInternetChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final hasNet = _hasInternet(result);
      if (_isConnected.value != hasNet) {
        _isConnected.value = hasNet;
      }
    });
  }

  bool _hasInternet(List<ConnectivityResult> result) {
    if (result.isEmpty || result.contains(ConnectivityResult.none)) {
      return false;
    }
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet) ||
        result.contains(ConnectivityResult.vpn);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _isConnected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ CRITICAL FIX: The Navigator (widget.child) is returned directly as the base
    // of this widget. We use a ValueListenableBuilder inside a Stack to overlay the
    // NoInternetScreen without EVER modifying the Navigator's position in the tree.
    // This avoids the "elements.contains(element): is not true" assertion crash.
    return Stack(
      children: [
        // The Navigator subtree. It stays permanently mounted at the bottom of the stack.
        widget.child,

        // The No-Internet overlay. It uses Visibility/Opacity to remain in the tree
        // structure even when hidden, ensuring the Widget Tree remains identical.
        ValueListenableBuilder<bool>(
          valueListenable: _isConnected,
          builder: (context, connected, _) {
            return IgnorePointer(
              ignoring: connected,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: connected ? 0.0 : 1.0,
                child: NoInternetScreen(
                  onRetry: _checkConnectivity,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

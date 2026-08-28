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
    // 🛡️ CRITICAL: Do NOT check connectivity during initState. 
    // This avoids race conditions during the very first build cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivity();
      _listenInternetChanges();
    });
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
    // 🛡️ Tree corruption fix: Always keep the same structure in the Stack.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          ValueListenableBuilder<bool>(
            valueListenable: _isConnected,
            builder: (context, connected, _) {
              // Using Visibility with maintainState: true keeps the tree identical
              // preventing the "_elements.contains(element): is not true" crash.
              return Visibility(
                visible: !connected,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Material(
                  child: NoInternetScreen(
                    onRetry: _checkConnectivity,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

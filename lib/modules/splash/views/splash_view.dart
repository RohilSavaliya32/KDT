import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/routes/app_routes.dart';
import 'package:kdt/services_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  ServicesController? _servicesController;

  @override
  void initState() {
    super.initState();
    
    // Safety check for controller
    if (Get.isRegistered<ServicesController>()) {
      _servicesController = Get.find<ServicesController>();
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();

    // Check if ready already
    if (_servicesController?.isReady.value == true) {
      _navigateToNext();
      return;
    }

    // Listen to services readiness
    if (_servicesController != null) {
      ever(_servicesController!.isReady, (bool ready) {
        if (ready) {
          _navigateToNext();
        }
      });
    }

    // Fallback delay (3 seconds max) to prevent getting stuck
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    if (mounted) {
      Get.offAllNamed(AppRoutes.navigation);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/shapes/logo.png',
                width: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF005234),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

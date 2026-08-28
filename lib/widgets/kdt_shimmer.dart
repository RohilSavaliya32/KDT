import 'package:flutter/material.dart';

class KdtShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const KdtShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<KdtShimmer> createState() => _KdtShimmerState();
}

class _KdtShimmerState extends State<KdtShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: _SlidingGradientTransform(offset: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double offset;

  const _SlidingGradientTransform({required this.offset});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (offset * 3 - 1.5), 0, 0);
  }
}

class KdtSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const KdtSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  const KdtSkeleton.circle({
    super.key,
    double? size,
  })  : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class DiamondCardSkeleton extends StatelessWidget {
  const DiamondCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: KdtSkeleton(borderRadius: 16),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: KdtSkeleton(height: 16)),
                    const SizedBox(width: 8),
                    const KdtSkeleton(width: 30, height: 16),
                  ],
                ),
                const SizedBox(height: 8),
                const KdtSkeleton(width: 120, height: 12),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: KdtSkeleton(height: 10)),
                    const SizedBox(width: 8),
                    const Expanded(child: KdtSkeleton(height: 10)),
                  ],
                ),
                const Divider(height: 20),
                const KdtSkeleton(width: 80, height: 20),
                const SizedBox(height: 4),
                const KdtSkeleton(width: 60, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

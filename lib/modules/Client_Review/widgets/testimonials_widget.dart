import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../models/testimonial_model.dart';
import '../services/testimonials_service.dart';

class TestimonialsWidget extends StatefulWidget {
  const TestimonialsWidget({Key? key}) : super(key: key);

  @override
  State<TestimonialsWidget> createState() =>
      _TestimonialsWidgetState();
}

class _TestimonialsWidgetState extends State<TestimonialsWidget> {
  List<Testimonial> _testimonials = [];
  bool _isLoading = true;
  String? _error;

  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  );

  int _currentPage = 0;
  double? _cardHeight;

  double _lastMeasureWidth = 0;
  int _lastMeasureCount = 0;

  final List<GlobalKey> _cardKeys = [];

  @override
  void initState() {
    super.initState();
    _fetchTestimonials();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTestimonials() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = TestimonialsService();
      final testimonials = await service.fetchTestimonials();

      setState(() {
        _testimonials = testimonials;
        _isLoading = false;
        _cardHeight = null;

        _cardKeys
          ..clear()
          ..addAll(
            List.generate(
              testimonials.length,
                  (_) => GlobalKey(),
            ),
          );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureCardHeights();
      });
    } catch (e) {
      setState(() {
        _error =
        'Failed to load testimonials. Please try again.';
        _isLoading = false;
        _testimonials = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Empty state -> Hide complete component
    if (!_isLoading &&
        (_error == null || _error!.isEmpty) &&
        _testimonials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 16,
      ),
      color: AppColors.app_back,
      child: Column(
        children: [
          _buildHeader(),

          const SizedBox(height: 32),

          if (_isLoading)
            _buildLoadingState()
          else if (_error != null && _error!.isNotEmpty)
            _buildErrorState()
          else
            _buildHorizontalScroll(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'CLIENT STORIES',
          style: AppTextStyles.poppins(
            fontSize: 12,
            letterSpacing: 4,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'What Our Clients Say',
          textAlign: TextAlign.center,
          style: AppTextStyles.lora(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Text(
            'Join thousands of satisfied customers who found their perfect diamond with us',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalScroll() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth * 0.85;

        _scheduleCardMeasurement(pageWidth);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Extra bottom space for card shadow
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: SizedBox(
                height: _cardHeight == null
                    ? 0
                    : _cardHeight! + 24,
                child: _cardHeight == null
                    ? const SizedBox.shrink()
                    : PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.none,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _testimonials.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        0,
                        8,
                        24,
                      ),
                      child: _buildTestimonialCard(
                        _testimonials[index],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Hidden measurement cards
            IgnorePointer(
              child: Offstage(
                child: Column(
                  children: List.generate(
                    _testimonials.length,
                        (index) => SizedBox(
                      width: pageWidth - 16,
                      child: _buildTestimonialCard(
                        _testimonials[index],
                        key: _cardKeys.length > index
                            ? _cardKeys[index]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_testimonials.length > 1) ...[
              const SizedBox(height: 20),
              SmoothPageIndicator(
                controller: _pageController,
                count: _testimonials.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppColors.accent,
                  dotColor: Colors.grey.shade300,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _scheduleCardMeasurement(double pageWidth) {
    if (_lastMeasureWidth == pageWidth &&
        _lastMeasureCount == _testimonials.length &&
        _cardHeight != null) {
      return;
    }

    _lastMeasureWidth = pageWidth;
    _lastMeasureCount = _testimonials.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureCardHeights();
    });
  }

  void _measureCardHeights() {
    if (!mounted || _cardKeys.isEmpty) return;

    double maxHeight = 0;

    for (final key in _cardKeys) {
      final renderObject =
      key.currentContext?.findRenderObject();

      if (renderObject is RenderBox &&
          renderObject.hasSize) {
        maxHeight = maxHeight < renderObject.size.height
            ? renderObject.size.height
            : maxHeight;
      }
    }

    if (maxHeight <= 0) return;

    if (_cardHeight == null ||
        (_cardHeight! - maxHeight).abs() > 0.5) {
      setState(() {
        _cardHeight = maxHeight;
      });
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.accent,
            ),
            SizedBox(height: 16),
            Text(
              'Loading client stories...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),

            const SizedBox(height: 16),

            Text(
              _error ??
                  'Currently, reviews are not available. Please try again later.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _fetchTestimonials,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(
      Testimonial testimonial, {
        Key? key,
      }) {
    return Stack(
      key: key,
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),

            // Soft shadow with enough space to render fully
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],

            border: Border.all(
              color: const Color(0xFFF0EDE8),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stars Rating
              _buildStars(testimonial.rating),

              const SizedBox(height: 12),

              // Verified Badge
              if (testimonial.verified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius:
                    BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: Colors.green[700],
                      ),

                      const SizedBox(width: 4),

                      Text(
                        'Verified Review',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Review Text
              Text(
                '"${testimonial.text}"',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: Color(0xFF2D2D2D),
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 1,
                color: const Color(0xFFE8E3DC),
              ),

              const SizedBox(height: 14),

              // Client Info
              Row(
                children: [
                  _buildProfileImage(testimonial),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          testimonial.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            fontFamily: 'Georgia',
                          ),
                        ),

                        if (testimonial.location.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            testimonial.location,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],

                        if (testimonial.diamond.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            testimonial.diamond,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.poppins(
                              fontSize: 12,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Quote Icon
        const Positioned(
          top: 20,
          right: 20,
          child: Icon(
            Icons.format_quote_rounded,
            size: 42,
            color: Color(0xFFD8E6E2),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(
      Testimonial testimonial,
      ) {
    final imageUrl =
    testimonial.profileImage?.isNotEmpty == true
        ? testimonial.profileImage!
        : testimonial.image?.isNotEmpty == true
        ? testimonial.image!
        : null;

    if (imageUrl == null) {
      return _buildDefaultAvatar(testimonial);
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        loadingBuilder:
            (context, child, progress) {
          if (progress == null) return child;

          return const SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return _buildDefaultAvatar(testimonial);
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(
      Testimonial testimonial,
      ) {
    final initials = testimonial.name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF3FAF7),
        border: Border.all(
          color: const Color(0xFFD5E7E0),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty
              ? initials.toUpperCase()
              : "?",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            color: AppColors.accent,
            size: 22,
          );
        }

        if (index < rating &&
            rating % 1 >= 0.5) {
          return const Icon(
            Icons.star_half,
            color: AppColors.accent,
            size: 22,
          );
        }

        return Icon(
          Icons.star_border,
          color: Colors.grey.shade300,
          size: 22,
        );
      }),
    );
  }
}
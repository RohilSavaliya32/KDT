import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/storage/api_constants.dart';
import '../../../data/Setting_Cont.dart';
import '../../../data/models/settings/contact_settings_model.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../Profile & Settings/Setting_Controller/Currency_Controller.dart';
import '../../Profile & Settings/currency_helper.dart';
import '../../Review/Review_Controller/Review_Controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../daimond_card/diamond_model.dart';
import '../../daimond_card/diamond_repository.dart';
import '../../../core/storage/secure_storage.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../wishlist/local_wishlist_storage.dart';
import '../../wishlist/wishlist_model.dart' as wishlist;

class DiamondDetailViewController extends GetxController {
  DiamondDetailViewController(this.repository);

  final DiamondRepository repository;

  final String baseUrl = ApiConstants.baseUrl;

  // Public website domain used for share links
  static const String webDomain = "https://www.kdtdiamond.com";

  final RxSet<String> wishlistIds = <String>{}.obs;
  final Rxn<DiamondModel> diamond = Rxn<DiamondModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAddedToCart = false.obs;
  final RxInt selectedImageIndex = 0.obs;
  final RxInt selectedNumber = 0.obs;
  final PageController imagePageController = PageController();
  final LocalWishlistStorage _localStorage = LocalWishlistStorage();
  SettingsDataController get settings => Get.find<SettingsDataController>();

  List<String> get phoneNumbers => [
    settings.home?.phone1 ?? '',
    settings.home?.phone2 ?? '',
  ].where((e) => e.isNotEmpty).toList();

  WishlistController get _wishlistController => Get.find<WishlistController>();

  // ============ INIT ============
  @override
  Future<void> onInit() async {
    super.onInit();

    final id = _extractId(Get.arguments);
    final slug = _extractSlug(Get.arguments);

    // Pehle slug se load karein (deep link), agar nahi toh id se
    if (slug != null && slug.isNotEmpty) {
      await loadDiamondBySlug(slug);
    } else if (id != null && id.isNotEmpty) {
      await loadDiamond(id);
    } else {
      errorMessage.value = 'Diamond not found';
      return;
    }

    await _loadWishlistStatus();
  }

  // ============ EXTRACT ID ============
  String? _extractId(dynamic arguments) {
    if (arguments is String) return arguments;
    if (arguments is Map) {
      final value = arguments['id'] ?? arguments['diamondId'];
      return value?.toString();
    }
    return null;
  }

  // ============ EXTRACT SLUG ============
  String? _extractSlug(dynamic arguments) {
    if (arguments is Map) {
      // Case 1: Direct slug parameter
      final slugValue = arguments['slug'];
      if (slugValue != null && slugValue.toString().isNotEmpty) {
        return slugValue.toString();
      }

      // Case 2: URL from deep link (e.g., https://kdtdiamond.com/brilliant-diamond)
      final urlValue = arguments['url'] ?? arguments['link'] ?? arguments['uri'];
      if (urlValue != null) {
        final str = urlValue.toString();
        if (str.contains('kdtdiamond.com')) {
          try {
            final uri = Uri.parse(str);
            final path = uri.path;
            if (path.isNotEmpty && path != '/') {
              // Remove leading slash and any trailing slash
              String slug = path.replaceAll('/', '');
              if (slug.endsWith('/')) {
                slug = slug.substring(0, slug.length - 1);
              }
              // Remove query parameters if any
              if (slug.contains('?')) {
                slug = slug.split('?').first;
              }
              return slug.isNotEmpty ? slug : null;
            }
          } catch (e) {
            debugPrint('Error parsing URL: $e');
          }
        }
      }
    }
    return null;
  }

  @override
  void onClose() {
    imagePageController.dispose();
    super.onClose();
  }

  // ============ LOAD WISHLIST STATUS ============
  Future<void> _loadWishlistStatus() async {
    try {
      final token = await SecureStorage.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      if (isLoggedIn) {
        await _wishlistController.loadWishlist();
        wishlistIds.assignAll(_wishlistController.wishlistIds.toSet());
      } else {
        final localIds = await _localStorage.loadWishlistIds();
        wishlistIds.assignAll(localIds.toSet());
      }

      if (kDebugMode) {
        debugPrint('================ WISHLIST STATUS ================');
        debugPrint('Logged In: $isLoggedIn');
        debugPrint('Wishlist IDs: ${wishlistIds.length}');
        debugPrint('==================================================');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading wishlist status: $e');
    }
  }

  // ============ LOAD DIAMOND BY ID ============
  Future<void> loadDiamond(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repository.getDiamondById(id);
      if (result == null) {
        errorMessage.value = 'Diamond not found';
        return;
      }

      diamond.value = result;
      selectedImageIndex.value = 0;

      final cartController = Get.find<CartController>();
      isAddedToCart.value = cartController.isInCart(result.id.toString());

      final reviewController = Get.find<ReviewController>();
      final authController = Get.find<AuthController>();
      reviewController.setCurrentUserId(authController.userId ?? '');
      await reviewController.loadReviews(id);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============ LOAD DIAMOND BY SLUG (deep link entry) ============
  Future<void> loadDiamondBySlug(String slug) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repository.getDiamondBySlug(slug);
      if (result == null) {
        errorMessage.value = 'Diamond not found';
        return;
      }

      diamond.value = result;
      selectedImageIndex.value = 0;

      final cartController = Get.find<CartController>();
      isAddedToCart.value = cartController.isInCart(result.id.toString());

      final reviewController = Get.find<ReviewController>();
      final authController = Get.find<AuthController>();
      reviewController.setCurrentUserId(authController.userId ?? '');
      await reviewController.loadReviews(result.id.toString());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  bool get isWishlisted {
    final d = diamond.value;
    if (d == null) return false;
    return wishlistIds.contains(d.id.toString());
  }

  void addToCart() {
    final d = diamond.value;
    if (d == null) return;

    final cartController = Get.find<CartController>();
    final itemId = d.id.toString();

    if (cartController.isInCart(itemId)) {
      isAddedToCart.value = true;
      AppNavigator.to("/navigation", arguments: {"tab": 3});
      return;
    }

    final cartItem = CartItemModel.fromDiamond(
      d.toJson(),
      initialQty: 1,
    );

    cartController.addItem(cartItem);
    isAddedToCart.value = true;

    Get.snackbar(
      'Added to Cart',
      'Diamond added successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
    AppNavigator.to("/navigation", arguments: {"tab": 3});
  }

  void shareViaWhatsApp() {
    Get.snackbar('Share', 'Share action placeholder');
  }

  void shareViaWebCart() {
    Get.snackbar('Share', 'Share action placeholder');
  }

  void bookAppointment() {
    Get.snackbar('Appointment', 'Booking action placeholder');
  }

  void changeNumber() {
    if (phoneNumbers.isEmpty) return;
    selectedNumber.value = (selectedNumber.value + 1) % phoneNumbers.length;
  }

  Future<void> openWhatsApp() async {
    final d = diamond.value;
    if (d == null) return;

    final contactSettings = Get.find<SettingsDataController>().contact;

    if (contactSettings == null) {
      Get.snackbar(
        "Error",
        "Contact settings not available",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final rawPhone = contactSettings.whatsappNumber;

    if (rawPhone == null || rawPhone.isEmpty) {
      Get.snackbar(
        "Error",
        "WhatsApp number not available",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // +, spaces, -, brackets remove
    final phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    final message = Uri.encodeComponent(
      "Hi, I am interested in this diamond:\n$title\n$priceText",
    );

    final uri = Uri.parse(
      "https://wa.me/$phone?text=$message",
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          "Error",
          "WhatsApp could not be opened",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("WhatsApp Error: $e");

      Get.snackbar(
        "Error",
        "Unable to open WhatsApp",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  Future<void> makePhoneCall() async {
    if (phoneNumbers.isEmpty) {
      Get.snackbar("Error", "Phone number not available");
      return;
    }

    final index = selectedNumber.value.clamp(0, phoneNumbers.length - 1);
    final rawPhone = phoneNumbers[index];
    final phone = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$phone');

    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        Get.snackbar("Error", "Phone dialer could not be opened");
      }
    } catch (e) {
      Get.snackbar("Error", "Unable to open phone dialer");
    }
  }

  bool get alreadyInCart {
    final d = diamond.value;
    if (d == null) return false;
    return Get.find<CartController>().isInCart(d.id.toString());
  }

  String get title {
    final d = diamond.value;
    if (d == null) return '';
    return d.localizedContent.name?.isNotEmpty == true
        ? d.localizedContent.name!
        : '${d.carat}ct ${d.shape} Diamond';
  }

  String get subtitleText {
    final d = diamond.value;
    if (d == null) return 'N/A';
    return '${d.cut.isNotEmpty ? d.cut : 'Excellent Cut'} • ${d.color} Color • ${d.clarity} Clarity';
  }

  String get priceText {
    final d = diamond.value;
    if (d == null) return '\$0';

    final currencyController = Get.find<CurrencyController>();

    final code = currencyController.selectedCurrency.value;
    final symbol = currencyController.selectedSymbol.value?.isNotEmpty == true
        ? currencyController.selectedSymbol.value!
        : CurrencyHelper.symbol(code);

    final amount =
        d.price.toDouble() * currencyController.selectedRate.value;

    final locale = (code == 'INR' || code == 'NPR' || code == 'BTN')
        ? 'en_IN'
        : 'en_US';

    final formatted = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 0,
    ).format(amount);

    return '$symbol$formatted';
  }

  String get pricePerCaratText {
    final d = diamond.value;
    if (d == null || d.carat == 0) return '0';

    final currencyController = Get.find<CurrencyController>();

    final code = currencyController.selectedCurrency.value;
    final symbol = currencyController.selectedSymbol.value?.isNotEmpty == true
        ? currencyController.selectedSymbol.value!
        : CurrencyHelper.symbol(code);
    final amount = (d.price.toDouble() / d.carat.toDouble()) *
        currencyController.selectedRate.value;

    final locale = (code == 'INR' || code == 'NPR' || code == 'BTN')
        ? 'en_IN'
        : 'en_US';

    final formatted = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 0,
    ).format(amount);

    return '$symbol$formatted';
  }

  String get diamondTitle {
    final d = diamond.value;
    if (d == null) return '';
    return d.title;
  }

  List<String> get images {
    final d = diamond.value;
    if (d == null) return const [];
    if (d.images.isNotEmpty) return d.images;
    if ((d.image ?? '').isNotEmpty) return [d.image!];
    return const [];
  }

  // ============ TOGGLE WISHLIST ============
  Future<void> toggleWishlist() async {
    final d = diamond.value;
    if (d == null) return;

    final diamondId = d.id.toString();
    final token = await SecureStorage.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    // Current state save karo
    final wasWishlisted = wishlistIds.contains(diamondId);

    // UI immediately update karo
    if (wasWishlisted) {
      wishlistIds.remove(diamondId);
    } else {
      wishlistIds.add(diamondId);
    }

    wishlistIds.refresh();

    try {
      // =========================
      // GUEST USER
      // =========================
      if (!isLoggedIn) {
        if (wasWishlisted) {
          await _localStorage.removeItem(diamondId);
        } else {
          final wishlistItem = _diamondToWishlistItem(d);
          await _localStorage.addItem(wishlistItem);
        }

        return;
      }

      // =========================
      // LOGGED IN USER
      // =========================
      final wishlistItem = _diamondToWishlistItem(d);

      final success =
      await _wishlistController.toggleWishlistByItem(wishlistItem);

      if (!success) {
        // API fail → previous state restore
        if (wasWishlisted) {
          wishlistIds.add(diamondId);
        } else {
          wishlistIds.remove(diamondId);
        }

        wishlistIds.refresh();

        Get.snackbar(
          'Error',
          'Failed to update wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        // API success → server state ke according sync
        wishlistIds.assignAll(
          _wishlistController.wishlistIds.toSet(),
        );

        wishlistIds.refresh();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Toggle Wishlist Error: $e');
      }

      // Error → previous state restore
      if (wasWishlisted) {
        wishlistIds.add(diamondId);
      } else {
        wishlistIds.remove(diamondId);
      }

      wishlistIds.refresh();

      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  // ============ CONVERT DIAMOND TO WISHLIST ITEM ============
  wishlist.WishlistItem _diamondToWishlistItem(DiamondModel diamond) {
    final id = diamond.id.toString();

    return wishlist.WishlistItem(
      id: id,
      cut: diamond.cut,
      sku: diamond.sku,
      slug: diamond.slug,
      carat: diamond.carat.toInt(),
      color: diamond.color,
      image: diamond.image,
      price: diamond.price.toInt(),
      shape: diamond.shape,
      title: diamond.title,
      images: diamond.images,
      polish: diamond.polish,
      clarity: diamond.clarity,
      buyCount: diamond.buyCount,
      quantity: diamond.quantity,
      seoTitle: diamond.seoTitle.isNotEmpty ? diamond.seoTitle : null,
      symmetry: diamond.symmetry,
      createdAt: diamond.createdAt,
      updatedAt: diamond.updatedAt,
      certNumber: diamond.certNumber,
      isLabGrown: diamond.isLabGrown,
      ratingCount: diamond.ratingCount,
      reviewCount: diamond.reviewCount,
      seoKeywords: diamond.seoKeywords,
      depthPercent: diamond.depthPercent.toInt(),
      fluorescence: diamond.fluorescence,
      measurements: wishlist.Measurements(
        depth: diamond.measurements.depth.toInt(),
        width: diamond.measurements.width.toInt(),
        length: diamond.measurements.length.toInt(),
      ),
      tablePercent: diamond.tablePercent.toInt(),
      averageRating: diamond.averageRating.toInt(),
      certification: diamond.certification,
      originalPrice: diamond.originalPrice.toInt(),
      seoDescription:
      diamond.seoDescription.isNotEmpty ? diamond.seoDescription : null,
      certificateFile: diamond.certificateFile.isNotEmpty
          ? diamond.certificateFile
          : null,
      discountPercent: diamond.discountPercent,
      localizedContent: wishlist.LocalizedContent(
        name: diamond.localizedContent.name,
        description: diamond.localizedContent.description,
        shapeName: diamond.localizedContent.shapeName,
        cutDetails: diamond.localizedContent.cutDetails,
        certificationInfo: diamond.localizedContent.certificationInfo,
        specifications: diamond.localizedContent.specifications,
        marketingContent: diamond.localizedContent.marketingContent,
        seoTitle: diamond.localizedContent.seoTitle,
        seoDescription: diamond.localizedContent.seoDescription,
        seoKeywords: diamond.localizedContent.seoKeywords,
      ),
    );
  }

  // ============ REFRESH WISHLIST STATUS ============
  Future<void> refreshWishlistStatus() async {
    await _loadWishlistStatus();
  }

  // ============ VIEW CERTIFICATE ============
  Future<void> viewCertificate() async {
    final d = diamond.value;
    if (d == null) return;

    final String certType = d.certification.isNotEmpty ? d.certification : "Certificate";
    final String certNum = d.certNumber.isNotEmpty ? d.certNumber : "N/A";
    final String fileUrl = d.certificateFile;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
            final maxHeight = constraints.maxHeight > 800 ? 800.0 : constraints.maxHeight;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dialog Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$certType Certificate - #$certNum',
                                  style: AppTextStyles.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: Get.back,
                                icon: Icon(Icons.cancel_outlined, color: Colors.grey.shade400, size: 28),
                              ),
                            ],
                          ),
                        ),

                        // Dialog Content
                        Flexible(
                          child: fileUrl.isEmpty || fileUrl == ""
                              ? _buildCertificatePlaceholder(certType, certNum)
                              : _buildCertificateImage(fileUrl),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildCertificatePlaceholder(String certType, String certNum) {
    String websiteUrl = "";
    if (certType.toUpperCase().contains("GIA")) {
      websiteUrl = "https://www.gia.edu/report-check?reportno=$certNum";
    } else if (certType.toUpperCase().contains("IGI")) {
      websiteUrl = "https://www.igi.org/verify-your-report/?report_number=$certNum";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              certType.toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Diamond Grading Report",
            style: AppTextStyles.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Report Number: $certNum",
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 30),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 30),
          Text(
            "This certificate is automatically being downloaded. You can also view the official certificate online:",
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: AppColors.darkGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (websiteUrl.isNotEmpty && certNum != "N/A")
            InkWell(
              onTap: () => launchUrl(Uri.parse(websiteUrl)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View on $certType Website",
                    style: AppTextStyles.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.accent),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCertificateImage(String fileUrl) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('Certificate image not found'),
            ],
          ),
        ),
      ),
    );
  }

  // ============ SHARE DIAMOND ============
  Future<void> shareDiamond([Rect? sharePositionOrigin]) async {
    final d = diamond.value;
    if (d == null) return;

    // ✅ Website format: https://kdtdiamond.com/brilliant-diamond
    final shareUrl = '$webDomain/${d.slug}';

    final titleText = d.certification.isNotEmpty ? d.certification : 'Diamond Certificate';
    final priceText = _formatPrice(d.price);

    final imageUrl = images.first;
    final shareText = '''
    💎 $titleText
    $diamondTitle
    Carat: ${d.carat} ct
    Shape: ${d.shape}
    Color: ${d.color}
    Clarity: ${d.clarity}
    Cut: ${d.cut}
    Price: $priceText

    View More Details:
    $shareUrl
    ''';

    try {
      if (imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
        try {
          final file = await _downloadImageToTemp(imageUrl, d.id);
          await Share.shareXFiles(
            [XFile(file.path)],
            text: shareText,
            subject: '$titleText - #${d.certNumber}',
            sharePositionOrigin: sharePositionOrigin,
          );
          return;
        } catch (e) {
          debugPrint('Image download failed: $e');
        }
      }

      await Share.share(
        shareText,
        subject: '$titleText - #${d.certNumber}',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint('shareDiamond error: $e');
      await Share.share(
        shareText,
        subject: '$titleText - #${d.certNumber}',
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }

  String _formatPrice(double price) {
    return '₹${price.toStringAsFixed(0)}';
  }

  Future<File> _downloadImageToTemp(String imageUrl, dynamic id) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'diamond_${id.toString()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${tempDir.path}/$fileName';

    await Dio().download(
      imageUrl,
      filePath,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
      ),
    );

    return File(filePath);
  }

  // ============ APPOINTMENT METHODS ============
  Future<void> openIndiaAppointment(ContactSettingsModel settings) async {
    debugPrint("India Link = ${settings.calendlyIndia}");
    final indiaLink = settings.calendlyIndia;
    if (indiaLink != null && indiaLink.isNotEmpty) {
      await openAppointmentUrl(indiaLink);
    } else {
      Get.snackbar(
        "Not Available",
        "India appointment link is not available",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> openKoreaAppointment(ContactSettingsModel settings) async {

    final koreaLink = settings.calendlyKorea;
    if (koreaLink != null && koreaLink.isNotEmpty) {
      await openAppointmentUrl(koreaLink);
    } else {
      Get.snackbar(
        "Not Available",
        "Korea appointment link is not available",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> openAppointmentUrl(String url) async {
    final Uri uri = Uri.parse(url.trim());

    debugPrint("Launching: $uri");

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      debugPrint("Launch Result: $launched");

      if (!launched) {
        Get.snackbar(
          "Error",
          "Unable to open browser",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("Launch Error: $e");
    }
  }

  Future<void> openAppointmentByType(String type) async {
    final settings = Get.find<SettingsDataController>().contact;

    if (settings == null) {
      Get.snackbar(
        "Error",
        "Contact settings not available",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (type == 'india') {
      await openIndiaAppointment(settings);
    } else if (type == 'korea') {
      await openKoreaAppointment(settings);
    }
  }

  Future<void> openKakao(ContactSettingsModel settings) async {
    final kakaoId = settings.kakaoId;

    if (kakaoId == null || kakaoId.isEmpty) {
      Get.snackbar(
        "Not Available",
        "Kakao ID is not available",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final url = "https://open.kakao.com/o/$kakaoId";
    await openAppointmentUrl(url);
  }

  Future<void> openWechat(ContactSettingsModel settings) async {
    final wechatId = settings.wechatId;

    if (wechatId == null || wechatId.isEmpty) {
      Get.snackbar(
        "Not Available",
        "WeChat ID is not available",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("WeChat"),
        content: Text("WeChat ID: $wechatId"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
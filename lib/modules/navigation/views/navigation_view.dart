import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/dimonds/views/diamonds_view.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../../utils/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/views/cart_view.dart';
import '../../daimond_card/controllers/daimond_card_controller.dart';
import '../../home/views/home_view.dart';
import '../../login/views/login_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';
import '../../translations/Translation_controllers/language_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../../translations/language_dropdown.dart';
import '../controllers/navigation_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class NavigationView extends StatelessWidget {
  NavigationView({super.key});

  final NavigationController controller = Get.find<NavigationController>();
  final ProfileController profileController = Get.find<ProfileController>();

  final List<Widget> pages = const [
    HomeView(),
    SearchView(),
    DiamondsView(),
    CartView(),
    ProfileView(),
  ];

  // Fixed visual height of the nav bar content (icons + labels),
  // NOT including the device's bottom safe-area inset.
  // Increased from 76 -> 88 to give the BottomNavigationBar's
  // internal icon+label column enough room on iOS, where font
  // metrics for Lora/Poppins render slightly taller and were
  // causing a 2px RenderFlex bottom overflow on every nav item.
  static const double _navBarContentHeight = 88;

  // Extra breathing room above the icons and below the labels
  // (on top of the device's bottom safe-area inset).
  static const double _navBarTopPadding = 10;
  static const double _navBarBottomPadding = 8;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Obx(
          () => Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: SafeArea(
          bottom: false,
          child: _buildBody(),
        ),
        // NOTE: No outer SafeArea here anymore.
        // We handle the bottom inset manually inside
        // _buildBottomNavigationBar so the height stays
        // consistent across iOS (home indicator) and
        // Android (gesture bar / no gesture bar).
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    final currentIndex = controller.currentIndex.value;

    if (currentIndex == 4) {
      return null;
    }

    if (currentIndex == 1) {
      return _buildSearchAppBar();
    }

    return _buildDefaultAppBar();
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 120,
      centerTitle: false,
      title: _buildSearchHeader(),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: _buildLogo(),
      actions: [
        _buildLanguageIcon(),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildProfileButton(),
        ),
      ],
    );
  }

  Widget _buildLanguageIcon() {
    return IconButton(
      onPressed: () {
        _showLanguageBottomSheet();
      },
      icon: const Icon(
        Icons.language,
        color: Color(0xFF0F5B45),
        size: 26,
      ),
      tooltip: TranslationKeys.changeLanguage.tr,
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageBottomSheet(),
    );
  }

  Widget _buildSearchHeader() {
    return GetBuilder<LanguageController>(
      builder: (langController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                TranslationKeys.searchYourDreamDiamonds.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.lora(
                  color: const Color(0xFF0F5B45),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildSearchField(),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: (value) {
          Get.find<DiamondCardController>().searchDiamonds(value);
        },
        decoration: InputDecoration(
          hintText: TranslationKeys.searchDiamonds.tr,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 22,
      child: Image.asset(
        'assets/shapes/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildProfileButton() {
    return Obx(() {
      final authController = Get.find<AuthController>();
      final isLoggedIn = authController.isLoggedIn.value;
      final userName = profileController.name.value.trim();

      return IconButton(
        onPressed: _handleProfileTap,
        icon: _buildProfileAvatar(isLoggedIn, userName),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        tooltip:
        isLoggedIn ? TranslationKeys.profile.tr : TranslationKeys.login.tr,
      );
    });
  }

  Widget _buildProfileAvatar(bool isLoggedIn, String userName) {
    final imageUrl = profileController.profileImage.value;

    return isLoggedIn
        ? CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFE5E5E5),
      backgroundImage:
      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isEmpty
          ? Text(
        _getProfileInitial(userName),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      )
          : null,
    )
        : Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.foreground,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        "Login",
        style: AppTextStyles.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getProfileInitial(String userName) {
    return userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : "?";
  }

  Widget _buildBody() {
    return Container(
      color: Colors.white,
      child: pages[controller.currentIndex.value],
    );
  }

  Widget _buildBottomNavigationBar() {
    return GetBuilder<LanguageController>(
      builder: (langController) {
        return Builder(
          builder: (context) {
            // Real device bottom safe-area inset:
            // - iOS with home indicator: ~34
            // - iOS with home button: 0
            // - Android gesture nav: ~16-48 depending on device
            // - Android 3-button nav: 0 (system nav bar handles it)
            final double bottomInset = MediaQuery.of(context).padding.bottom;

            // On devices with a big bottom inset (iPhone home
            // indicator), that inset already provides enough
            // breathing room below the labels — adding our own
            // fixed padding on top of it made iOS look like it
            // had a huge extra margin. Only add the extra padding
            // when there's little/no system inset (Android
            // 3-button nav, iPhones with a home button).
            final double effectiveBottomPadding =
            bottomInset > 0 ? bottomInset : _navBarBottomPadding;

            return Container(
              height: _navBarContentHeight +
                  _navBarTopPadding +
                  effectiveBottomPadding,
              decoration: _buildBottomNavDecoration(),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                child: Padding(
                  // Push the actual nav bar content up above the
                  // home indicator / gesture bar instead of
                  // stacking a second SafeArea on top of a fixed
                  // height container, plus a little extra
                  // breathing room top and bottom.
                  padding: EdgeInsets.only(
                    top: _navBarTopPadding,
                    bottom: effectiveBottomPadding,
                  ),
                  child: SizedBox(
                    height: _navBarContentHeight,
                    child: BottomNavigationBar(
                      // Removed the fixed `height: 1.2` on label
                      // styles — that was adding extra vertical
                      // space to each label's line box, which
                      // combined with the fixed SizedBox height
                      // caused a ~2px RenderFlex bottom overflow
                      // on iOS for every nav item.
                      selectedLabelStyle: const TextStyle(),
                      unselectedLabelStyle: const TextStyle(),
                      currentIndex: controller.currentIndex.value,
                      onTap: _handleBottomNavTap,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: AppColors.accent,
                      unselectedItemColor: Colors.grey,
                      selectedFontSize: 12,
                      unselectedFontSize: 11,
                      items: _buildNavItems(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  BoxDecoration _buildBottomNavDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(35),
        topRight: Radius.circular(35),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 20,
          offset: Offset(0, -5),
        ),
      ],
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      // =========================================================
      // Home
      // =========================================================
      BottomNavigationBarItem(
        icon: const Icon(
          Icons.home_outlined,
          size: 22,
        ),
        activeIcon: const Icon(
          Icons.home_outlined,
          size: 22,
        ),
        label: TranslationKeys.home.tr.toUpperCase(),
      ),

      // =========================================================
      // Search
      // =========================================================
      BottomNavigationBarItem(
        icon: const Icon(
          Icons.search,
          size: 22,
        ),
        activeIcon: const Icon(
          Icons.search,
          size: 22,
        ),
        label: TranslationKeys.search.tr.toUpperCase(),
      ),

      // =========================================================
      // Shop / Diamond
      // =========================================================
      BottomNavigationBarItem(
        icon: const Icon(
          Icons.grid_view_outlined,
          size: 22,
        ),
        activeIcon: const Icon(
          Icons.grid_view_outlined,
          size: 22,
        ),
        label: TranslationKeys.diamond.tr.toUpperCase(),
      ),

      // =========================================================
      // Cart
      // =========================================================
      BottomNavigationBarItem(
        icon: GetX<CartController>(
          builder: (cartController) {
            final count = cartController.cartItems.length;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 22,
                ),
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? "99+" : "$count",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        activeIcon: GetX<CartController>(
          builder: (cartController) {
            final count = cartController.cartItems.length;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 22,
                ),
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 10 ? "10+" : "$count",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        label: TranslationKeys.cart.tr.toUpperCase(),
      ),

      // =========================================================
      // Profile
      // =========================================================
      BottomNavigationBarItem(
        icon: const Icon(
          Icons.person_outline,
          size: 22,
        ),
        activeIcon: const Icon(
          Icons.person_outline,
          size: 22,
        ),
        label: TranslationKeys.profile.tr.toUpperCase(),
      ),
    ];
  }

  void _handleBottomNavTap(int index) {
    debugPrint("BOTTOM TAB CLICK => $index");

    if (index == 4) {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value) {
        showLoginModalDialog(
          Get.context!,
          onLoginSuccess: () {
            controller.changeTab(0);
          },
        );
        return;
      }
    }

    controller.changeTab(index);
  }

  void _handleProfileTap() {
    final authController = Get.find<AuthController>();

    if (!authController.isLoggedIn.value) {
      // If not logged in, show login dialog
      showLoginModalDialog(
        Get.context!,
        onLoginSuccess: () {
          // After successful login, navigate to profile
          controller.changeTab(0);
        },
      );
      return;
    }

    // If logged in, navigate to profile
    controller.changeTab(4);
  }
}
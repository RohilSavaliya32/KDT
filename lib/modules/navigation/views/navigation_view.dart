import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kdt/modules/dimonds/views/diamonds_view.dart';
import 'package:kdt/utils/app_decorations.dart';
import 'package:kdt/utils/app_text_style.dart';
import 'package:kdt/widgets/kdt_shimmer.dart';
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
import '../../../internet_check_wrapper.dart';

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

  static const double _navBarContentHeight = 88;
  static const double _navBarTopPadding = 0;
  static const double _navBarBottomPadding = 0;

  @override
  Widget build(BuildContext context) {
    return InternetCheckWrapper(
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
          boldText: false,
        ),
        child: _buildScaffold(),
      ),
    );
  }

  Widget _buildScaffold() {
    return Obx(
          () => Scaffold(
        backgroundColor: AppColors.appBack,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(),
        body: SafeArea(
          bottom: false,
          child: _buildBody(),
        ),
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
      backgroundColor: AppColors.appBack,
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: _buildSearchField(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBack,
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

  Widget _buildSearchField() {
    return GetBuilder<LanguageController>(
      builder: (langController) {
        return Container(
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
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
      },
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
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const KdtShimmer(
                        child: KdtSkeleton.circle(),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : Center(
                      child: Text(
                        _getProfileInitial(userName),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: AppFontSizes.s16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
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
          fontSize: AppFontSizes.s13,
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
    return Obx(
      () {
        final isMovingForward = controller.currentIndex.value >= controller.previousIndex.value;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isEntering = (child.key as ValueKey<int>).value == controller.currentIndex.value;

            return ClipRect(
              child: FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: isEntering
                        ? (isMovingForward ? const Offset(0.08, 0.0) : const Offset(-0.08, 0.0))
                        : (isMovingForward ? const Offset(-0.08, 0.0) : const Offset(0.08, 0.0)),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(controller.currentIndex.value),
            color: AppColors.appBack,
            child: pages[controller.currentIndex.value],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return GetBuilder<LanguageController>(
      builder: (langController) {
        return MediaQuery.removePadding(
          context: Get.context!,
          removeBottom: true,
          child: Container(
            height: _navBarContentHeight + _navBarTopPadding,
            decoration: _buildBottomNavDecoration(),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: _navBarTopPadding,
                ),
                child: SizedBox(
                  height: _navBarContentHeight,
                  child: MediaQuery.removePadding(
                    context: Get.context!,
                    removeBottom: true,
                    child: BottomNavigationBar(
                      selectedLabelStyle: const TextStyle(),
                      unselectedLabelStyle: const TextStyle(),
                      currentIndex: controller.currentIndex.value,
                      onTap: _handleBottomNavTap,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: AppColors.accent,
                      unselectedItemColor: Colors.grey,
                      selectedFontSize: AppFontSizes.s12,
                      unselectedFontSize: AppFontSizes.s11,
                      items: _buildNavItems(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildBottomNavDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(35),
        topRight: Radius.circular(35),
      ),
      boxShadow: AppDecorations.softShadow,
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
                            fontSize: AppFontSizes.s10,
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
                            fontSize: AppFontSizes.s10,
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
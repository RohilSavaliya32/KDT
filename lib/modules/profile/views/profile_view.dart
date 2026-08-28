import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import 'package:kdt/widgets/kdt_shimmer.dart';
import '../../../routes/app_routes.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../fade_slide_in.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  /// Direct navigation.
  /// Destination page will handle its own loading/data fetching.
  Future<void> _navigate(String route) async {
    await AppNavigator.to(route);
  }

  @override
  Widget build(BuildContext context) {
    // Disable text scaling for this screen
    final textScaleFactor = MediaQuery.of(context).textScaler;
    final isAccessibilityMode = textScaleFactor.scale(1) > 1.2;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF7F8F6),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.email.value.isEmpty) {
              return _ProfileShimmer();
            }

            return Column(
              children: [
                const SizedBox(height: 10),

                // HEADER
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Profile',
                    style: AppTextStyles.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // PROFILE CARD
                      FadeSlideIn(
                        duration: const Duration(milliseconds: 500),
                        slideOffset: 25,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: AppColors.accent,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Obx(() {
                                    final imageUrl =
                                        controller.profileImage.value;

                                    return Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFE5E5E5),
                                        border: Border.all(
                                          color: AppColors.glassWhite,
                                          width: 3,
                                        ),
                                        image: imageUrl.isNotEmpty
                                            ? DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                            : null,
                                      ),
                                      child: imageUrl.isEmpty
                                          ? Center(
                                        child: Text(
                                          controller.name.value
                                              .trim()
                                              .isNotEmpty
                                              ? controller.name.value
                                              .trim()[0]
                                              .toUpperCase()
                                              : "GU",
                                          style:
                                          AppTextStyles.poppins(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w400,
                                            color:
                                            AppColors.foreground,
                                          ),
                                        ),
                                      )
                                          : null,
                                    );
                                  }),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.name.value,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.lora(
                                              color: AppColors.background,
                                              fontSize: 26,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.email_outlined,
                                                    size: 14,
                                                    color: Colors.white70,
                                                  ),

                                                  const SizedBox(width: 6),

                                                  Expanded(
                                                    child: Text(
                                                      controller.email.value,
                                                      style:
                                                      AppTextStyles.poppins(
                                                        color:
                                                        Colors.white70,
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              if (controller
                                                  .mobile.value.isNotEmpty)
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    top: 6,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.phone_outlined,
                                                        size: 14,
                                                        color: Colors.white70,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        controller.mobile.value,
                                                        style: AppTextStyles
                                                            .poppins(
                                                          color:
                                                          Colors.white70,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // USER INFORMATION
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        slideOffset: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Text(
                                "USER INFORMATION",
                                style: AppTextStyles.poppins(
                                  letterSpacing: 3,
                                  color: const Color(0xff7A857F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            const SizedBox(height: 12),

                            // EDIT PROFILE
                            _menuTile(
                              icon: Icons.edit_outlined,
                              title: "Edit Profile",
                              subtitle:
                              "Update your personal information",
                              onTap: () async {
                                controller.isEditProfileOpening.value = true;

                                try {
                                  // Latest profile data fetch
                                  await controller.refreshProfile();

                                  // Open Edit Profile page
                                  await AppNavigator.to(
                                    AppRoutes.EDIT_PROFILE,
                                  );
                                } catch (e) {
                                  debugPrint(
                                    "EDIT PROFILE OPEN ERROR => $e",
                                  );
                                } finally {
                                  controller.isEditProfileOpening.value =
                                  false;
                                }
                              },
                            ),

                            // ADDRESS
                            _menuTile(
                              icon: Icons.location_on_outlined,
                              title: "Addresses",
                              subtitle:
                              "Add, edit or remove your saved addresses",
                              onTap: () => _navigate(
                                AppRoutes.ADDRESS,
                              ),
                            ),

                            // NOTIFICATION
                            _menuTile(
                              icon: Icons.notifications_outlined,
                              title: "Notification Preferences",
                              subtitle:
                              "Manage your push notification settings",
                              onTap: () => _navigate(
                                AppRoutes.notificationPreferences,
                              ),
                            ),

                            // WISHLIST
                            _menuTile(
                              icon: Icons.favorite_border,
                              title: "My Wishlist",
                              subtitle:
                              "View and manage your favorite diamonds",
                              onTap: () => _navigate(
                                AppRoutes.WISHLIST,
                              ),
                            ),

                            // ORDERS
                            _menuTile(
                              icon: Icons.shopping_bag_outlined,
                              title: "Order History",
                              subtitle:
                              "Track and view all your past orders",
                              onTap: () => _navigate(
                                AppRoutes.ORDERS,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SHOPPING
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        slideOffset: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Text(
                                "SHOPPING",
                                style: AppTextStyles.poppins(
                                  letterSpacing: 3,
                                  color: const Color(0xff7A857F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // CURRENCY
                            _menuTile(
                              icon: Icons.currency_exchange,
                              title: "Currency Settings",
                              subtitle:
                              "Change your preferred currency",
                              onTap: () => _navigate(
                                AppRoutes.currency_selection,
                              ),
                            ),

                            // SIZE GUIDE
                            _menuTile(
                              icon: Icons.format_size_sharp,
                              title: "Diamond Size Guide",
                              subtitle:
                              "View approximate diamond sizes by shape and carat",
                              onTap: () => _navigate(
                                AppRoutes.SIZE_GUIDE,
                              ),
                            ),

                            // DIAMOND EDUCATION
                            _menuTile(
                              icon: Icons.diamond_outlined,
                              title: "Diamond Education",
                              subtitle:
                              "Understand natural & lab-grown diamonds",
                              onTap: () => _navigate(
                                AppRoutes.diamondEducation,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SUPPORT
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        slideOffset: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Text(
                                "SUPPORT",
                                style: AppTextStyles.poppins(
                                  letterSpacing: 3,
                                  color: const Color(0xff7A857F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // CONTACT SUPPORT
                            _menuTile(
                              icon: Icons.headset_mic_outlined,
                              title: "Contact Support",
                              subtitle:
                              "Get help from our customer service team",
                              onTap: () => _navigate(
                                AppRoutes.CONTACT_US,
                              ),
                            ),

                            // FAQ
                            _menuTile(
                              icon: Icons.help_outline,
                              title: "FAQ",
                              subtitle:
                              "Find answers to frequently asked questions",
                              onTap: () => _navigate(
                                AppRoutes.FAQ,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ABOUT
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        slideOffset: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Text(
                                "ABOUT",
                                style: AppTextStyles.poppins(
                                  letterSpacing: 3,
                                  color: const Color(0xff7A857F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ABOUT US
                            _menuTile(
                              icon: Icons.info_outline,
                              title: "About Our Company",
                              subtitle:
                              "Learn about KDT's story and values",
                              onTap: () => _navigate(
                                AppRoutes.ABOUT_US,
                              ),
                            ),

                            // TERMS
                            _menuTile(
                              icon: Icons.description_outlined,
                              title: "Terms & Conditions",
                              subtitle:
                              "Read our terms of service and policies",
                              onTap: () => _navigate(
                                AppRoutes.TERMS_CONDITIONS,
                              ),
                            ),

                            // PRIVACY
                            _menuTile(
                              icon: Icons.privacy_tip_outlined,
                              title: "Privacy Policy",
                              subtitle:
                              "Learn how we collect and protect your data",
                              onTap: () => _navigate(
                                AppRoutes.PRIVACY_POLICY,
                              ),
                            ),

                            // SHIPPING
                            _menuTile(
                              icon: Icons.local_shipping_outlined,
                              title: "Shipping Policy",
                              subtitle:
                              "View our shipping methods and delivery information",
                              onTap: () => _navigate(
                                AppRoutes.SHIPPING_POLICY,
                              ),
                            ),

                            // RETURNS
                            _menuTile(
                              icon: Icons.keyboard_return_outlined,
                              title: "Returns Policy",
                              subtitle:
                              "Learn about returns, refunds and exchanges",
                              onTap: () => _navigate(
                                AppRoutes.RETURN_POLICY,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SIGN OUT BUTTON
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 500),
                        slideOffset: 20,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Obx(
                                () => Column(
                              children: [
                                const Divider(
                                  color: Color(0xffE0E0E0),
                                  thickness: 1,
                                  height: 1,
                                ),

                                const SizedBox(height: 16),

                                InkWell(
                                  onTap:
                                  controller.isLoggingOut.value
                                      ? null
                                      : controller.logout,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        controller.isLoggingOut.value
                                            ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child:
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                            Color(0xffEF5350),
                                          ),
                                        )
                                            : const Icon(
                                          Icons.logout_rounded,
                                          color:
                                          Color(0xffEF5350),
                                          size: 22,
                                        ),

                                        const SizedBox(width: 12),

                                        Text(
                                          controller.isLoggingOut.value
                                              ? "Signing Out..."
                                              : "Sign Out",
                                          style:
                                          AppTextStyles.poppins(
                                            color:
                                            const Color(0xffEF5350),
                                            fontWeight:
                                            FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color:
                                          Color(0xffEF5350),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xffEEF2EF),
        child: Icon(
          icon,
          color: const Color(0xff0D4D3A),
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.poppins(
          fontSize: 13,
          color: const Color(0xff7A857F),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xff7A857F),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KdtShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          Center(child: KdtSkeleton(width: 100, height: 20)),
          const SizedBox(height: 20),
          // Profile Card Shimmer
          KdtSkeleton(
            height: 120,
            width: double.infinity,
            borderRadius: 28,
          ),
          const SizedBox(height: 30),
          // Section Title
          KdtSkeleton(width: 150, height: 14),
          const SizedBox(height: 16),
          // List Items
          ...List.generate(
            5,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  KdtSkeleton.circle(size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KdtSkeleton(width: 120, height: 16),
                        const SizedBox(height: 6),
                        KdtSkeleton(width: double.infinity, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String title;

  const _StatItem({
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.poppins(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

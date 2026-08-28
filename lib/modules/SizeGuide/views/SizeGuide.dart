import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/size_guide_controller.dart';

class SizeGuideView extends GetView<SizeGuideController> {
  const SizeGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF8F8F8),
        appBar: _buildAppBar(),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isDesktop = width > 900;
              final isTablet = width > 600;

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80 : (isTablet ? 40 : 20),
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Understand the visual scale of different diamond shapes and carat weights. "
                              "Dimensions are approximate and may vary slightly based on cut proportions.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.poppins(
                            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 35),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              /// Shape Selector Header
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "SELECT SHAPE",
                                            style: AppTextStyles.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              letterSpacing: 1,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "${controller.shapes.length} sizes available",
                                            style: AppTextStyles.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: AppColors.foreground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: isDesktop ? 220 : (isTablet ? 200 : 160),
                                      child: _CustomDropdown(
                                        value: controller.selectedShape.value,
                                        items: controller.shapes,
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.onShapeChanged(value);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),

                              /// Table Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Carat Weight",
                                        style: AppTextStyles.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Approx. Size (mm)",
                                      style: AppTextStyles.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.foreground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),

                              /// List Items
                              Obx(() {
                                final items = controller.currentData;

                                if (items.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 60,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No Size Guide Available",
                                        style: AppTextStyles.poppins(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = items[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${item.carat.toStringAsFixed(2)} ct",
                                              style: AppTextStyles.poppins(
                                                fontSize: isDesktop ? 15 : (isTablet ? 14 : 13),
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.foreground,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item.mmSize,
                                            style: AppTextStyles.poppins(
                                              fontSize: isDesktop ? 15 : (isTablet ? 14 : 13),
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                              Divider(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),

                              /// Note
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.poppins(
                                      fontSize: isDesktop ? 13 : (isTablet ? 12 : 11),
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Note: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                        "The millimeter dimensions for ${controller.selectedShape.value} diamonds are estimated averages. Actual dimensions can vary depending on the diamond's unique cut and depth percentage.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          CupertinoIcons.back,
          size: 24,
          color: AppColors.foreground,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "Diamond Size Guide",
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hint: Text(
            'Select Shape',
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
          ),
          iconSize: 24,
          elevation: 4,
          dropdownColor: Colors.white,
          style: AppTextStyles.poppins(
            fontSize: 14,
            color: AppColors.foreground,
          ),
          items: items
              .map(
                (shape) => DropdownMenuItem<String>(
              value: shape,
              child: Text(
                shape,
                style: AppTextStyles.poppins(
                  fontSize: 14,
                  color: AppColors.foreground,
                ),
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
          // This ensures dropdown opens below the field
          selectedItemBuilder: (context) {
            return items.map(
                  (shape) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    shape,
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      color: AppColors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ).toList();
          },
        ),
      ),
    );
  }
}
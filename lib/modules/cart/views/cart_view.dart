import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/widgets/kdt_shimmer.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../Profile & Settings/currency_price_text.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../login/views/login_view.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    // Prevent system text scaling from affecting UI
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;
            final contentWidth = isDesktop ? 1200.0 : double.infinity;

            return RefreshIndicator(
              onRefresh: () async => controller.refreshCart(),
              color: Colors.black,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Obx(() {
                    if (controller.isLoading.value && controller.cartItems.isEmpty) {
                      return _CartShimmer(
                        horizontalPadding: horizontalPadding,
                        isDesktop: isDesktop,
                        constraints: constraints,
                      );
                    }
                    if (controller.cartItems.isEmpty) {
                      return _buildEmptyCart(horizontalPadding, constraints);
                    }
                    return FadeSlideIn(
                      duration: const Duration(milliseconds: 500),
                      slideOffset: 15,
                      child: _buildCartContent(
                        horizontalPadding,
                        contentWidth,
                        constraints,
                        isDesktop,
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(double horizontalPadding, BoxConstraints constraints) {
    return FadeSlideIn(
      duration: const Duration(milliseconds: 500),
      slideOffset: 15,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48,
              maxWidth: 520,
            ),
            child: const _EmptyCartState(),
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent(
      double horizontalPadding,
      double contentWidth,
      BoxConstraints constraints,
      bool isDesktop,
      ) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
          maxWidth: contentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: isDesktop
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildCartItemsList(),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 380,
              child: _buildOrderSummaryCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCartItemsList(),
        const SizedBox(height: 18),
        _buildOrderSummaryCard(),
      ],
    );
  }

  Widget _buildCartItemsList() {
    return Obx(
          () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.cartItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _CartItemCard(
          controller.cartItems[index],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Obx(() {
        final subtotal = controller.cartItems.fold<double>(
          0.0,
              (sum, item) =>
          sum +
              (double.tryParse(item.price.toString()) ?? 0.0) *
                  item.quantity.value,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SectionTitle('Order Summary'),
            const SizedBox(height: 18),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 18),
            _SummaryRow('Subtotal', controller.formatCurrency(subtotal)),
            const SizedBox(height: 16),
            _SummaryRow('Shipping', 'Complimentary'),
            const SizedBox(height: 18),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 18),
            _SummaryRow('Total', controller.formatCurrency(subtotal), bold: true),
            const SizedBox(height: 24),
            _CheckoutButton(),
          ],
        );
      }),
    );
  }
}

class _CartShimmer extends StatelessWidget {
  final double horizontalPadding;
  final bool isDesktop;
  final BoxConstraints constraints;

  const _CartShimmer({
    required this.horizontalPadding,
    required this.isDesktop,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return KdtShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Column(
          children: [
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: List.generate(3, (index) => _itemShimmer()),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const KdtSkeleton(width: 380, height: 400, borderRadius: 12),
                ],
              )
            else
              Column(
                children: [
                  ...List.generate(2, (index) => _itemShimmer()),
                  const SizedBox(height: 20),
                  const KdtSkeleton(width: double.infinity, height: 300, borderRadius: 12),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KdtSkeleton(width: 140, height: 140, borderRadius: 8),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KdtSkeleton(width: double.infinity, height: 24, borderRadius: 4),
                const SizedBox(height: 10),
                const KdtSkeleton(width: 150, height: 16, borderRadius: 4),
                const SizedBox(height: 20),
                const KdtSkeleton(width: 100, height: 28, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Cart Item Card ---
class _CartItemCard extends StatelessWidget {
  const _CartItemCard(this.item);
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useColumn = constraints.maxWidth < 620;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 28, top: 6),
                child: useColumn
                    ? _buildCompactLayout()
                    : _buildWideLayout(),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => _removeItem(),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.grey.shade700,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Remove item',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemImage(image: item.image),
            const SizedBox(height: 12),
            _QuantityControl(item: item),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(child: _ItemDetails(item: item)),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemImage(image: item.image),
            const SizedBox(height: 12),
            _QuantityControl(item: item),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(child: _ItemDetails(item: item)),
      ],
    );
  }

  void _removeItem() {
    final controller = Get.find<CartController>();
    controller.removeItem(item);
  }
}

// --- Item Image ---
class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 140,
        height: 140,
        child: image.startsWith('http')
            ? Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_not_supported,
            size: 50,
          ),
        )
            : Image.asset(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_not_supported,
            size: 50,
          ),
        ),
      ),
    );
  }
}

// --- Quantity Control ---
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            onTap: () => controller.decreaseQty(item),
          ),
          Container(
            width: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Obx(
                  () => Text(
                '${item.quantity.value}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () => controller.increaseQty(item),
          ),
        ],
      ),
    );
  }
}

// --- Quantity Button ---
class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 40,
        child: Icon(icon, size: 18),
      ),
    );
  }
}

// --- Item Details ---
class _ItemDetails extends StatelessWidget {
  const _ItemDetails({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.diamondTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              fontFamily: 'serif',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          CurrencyPriceText(
            usdAmount: double.tryParse(item.price.toString()) ?? 0,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),        ],
      ),
    );
  }
}

// --- Summary Row ---
class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      this.label,
      this.value, {
        this.bold = false,
      });
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Section Title ---
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontFamily: 'serif',
      ),
    );
  }
}

// --- Checkout Button ---
class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final authController = Get.find<AuthController>();
          if (!authController.isLoggedIn.value) {
            Get.dialog(const LoginModalDialog());
            return;
          }
          AppNavigator.to("/checkout");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed to Checkout',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Empty Cart State ---
class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your cart is empty.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF5E6A75),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 190,
            height: 44,
            child: ElevatedButton(
              onPressed: () => AppNavigator.offAll("/navigation", arguments: 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: const Text(
                'Explore Diamonds',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

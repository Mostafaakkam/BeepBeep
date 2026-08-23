import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../../../../data/models/models.dart';
import '../../../orders/presentation/pages/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartViewModel _viewModel = CartViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadCart();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            tooltip: l10n.goBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.shoppingCart,
              style: const TextStyle(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return _buildLoadingState();
        }

        if (_viewModel.isError) {
          return _buildErrorState();
        }

        if (_viewModel.isEmpty) {
          return _buildEmptyState();
        }

        return _buildCartContent();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _viewModel.errorMessage ?? l10n.failedToLoadCart,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.retry,
              type: AppButtonType.primary,
              onPressed: _viewModel.retry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.emptyCart,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.emptyCartSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _viewModel.cart!.items.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_viewModel.cart!.items[index]);
            },
          ),
        ),
        _buildCartSummary(),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: item.product.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    child: Image.network(
                      item.product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.inventory_2,
                          color: AppColors.primary,
                          size: 32,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.inventory_2,
                    color: AppColors.primary,
                    size: 32,
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (item.variant.color != null ||
                    item.variant.size != null) ...[
                  Text(
                    '${item.variant.color ?? ''} ${item.variant.size ?? ''}'
                        .trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  item.variant.price.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            children: [
              _buildQuantityControls(item),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                onPressed: _viewModel.isOperationInProgress
                    ? null
                    : () => _viewModel.removeItem(item.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: _viewModel.isOperationInProgress
                ? null
                : () {
                    if (item.quantity > 1) {
                      _viewModel.updateItemQuantity(
                        cartItemId: item.id,
                        quantity: item.quantity - 1,
                      );
                    }
                  },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: _viewModel.isOperationInProgress
                ? null
                : () {
                    _viewModel.updateItemQuantity(
                      cartItemId: item.id,
                      quantity: item.quantity + 1,
                    );
                  },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.subtotalItems(_viewModel.itemCount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray,
                    ),
              ),
              Text(
                _viewModel.subtotal.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkNavy,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.deliveryFee,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray,
                    ),
              ),
              Text(
                '5.00',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkNavy,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.total,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                (_viewModel.total + 5.00).toStringAsFixed(2),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: l10n.checkout,
            type: AppButtonType.primary,
            isFullWidth: true,
            onPressed: _viewModel.isEmpty || _viewModel.isOperationInProgress
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CheckoutPage(),
                      ),
                    );
                  },
          ),
          if (!_viewModel.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              text: l10n.clearCart,
              type: AppButtonType.secondary,
              isFullWidth: true,
              onPressed: _viewModel.isOperationInProgress
                  ? null
                  : _viewModel.clearCart,
            ),
          ],
        ],
      ),
    );
  }
}

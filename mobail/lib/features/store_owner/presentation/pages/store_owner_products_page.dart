import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';
import '../viewmodels/owner_product_viewmodel.dart';
import '../viewmodels/store_owner_viewmodel.dart';
import 'product_form_page.dart';

// Store Owner Dashboard: product list for the currently selected store
// (StoreOwnerViewModel.selectedStore). Every product shown here already
// belongs to that store server-side -- GET /api/stores/:storeId/products is
// gated by requireStoreOwnership, so there is no id an owner could tamper
// with here to see another store's products.
class StoreOwnerProductsPage extends StatefulWidget {
  final StoreOwnerViewModel storeOwnerViewModel;
  final OwnerProductViewModel productViewModel;

  const StoreOwnerProductsPage({
    super.key,
    required this.storeOwnerViewModel,
    required this.productViewModel,
  });

  @override
  State<StoreOwnerProductsPage> createState() => _StoreOwnerProductsPageState();
}

class _StoreOwnerProductsPageState extends State<StoreOwnerProductsPage> {
  int? _loadedForStoreId;

  @override
  Widget build(BuildContext context) {
    final store = widget.storeOwnerViewModel.selectedStore;

    if (store == null) {
      return _buildNoStoreSelected(context);
    }

    if (_loadedForStoreId != store.id) {
      _loadedForStoreId = store.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.productViewModel.loadProducts(store.id);
      });
    }

    return ListenableBuilder(
      listenable: widget.productViewModel,
      builder: (context, child) {
        return Scaffold(
          body: _buildBody(context, store),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _openProductForm(context, store),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        );
      },
    );
  }

  Widget _buildNoStoreSelected(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n.selectAStoreFirst,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Store store) {
    final vm = widget.productViewModel;
    final l10n = AppLocalizations.of(context);

    if (vm.isLoading && vm.products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (vm.isError && vm.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                vm.errorMessage ?? l10n.failedToLoadProducts,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(text: l10n.retry, type: AppButtonType.primary, onPressed: vm.retry),
            ],
          ),
        ),
      );
    }

    if (vm.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.gray),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.noOwnedProducts,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.noOwnedProductsMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.retry,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 88),
        itemCount: vm.products.length,
        itemBuilder: (context, index) => _buildProductCard(context, store, vm.products[index]),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Store store, Product product) {
    final l10n = AppLocalizations.of(context);
    final firstImage = product.images.isNotEmpty ? product.images.first : null;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: firstImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    child: Image.network(
                      firstImage.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.inventory_2, color: AppColors.primary),
                    ),
                  )
                : const Icon(Icons.inventory_2, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildActiveBadge(context, product.isActive),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.variants.isNotEmpty
                      ? (product.hasPriceRange
                          ? '${product.lowestPrice.toStringAsFixed(2)} - ${product.highestPrice.toStringAsFixed(2)}'
                          : product.lowestPrice.toStringAsFixed(2))
                      : '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _openProductForm(context, store, existingProduct: product),
                      child: Text(l10n.edit),
                    ),
                    if (product.isActive)
                      TextButton(
                        onPressed: () => _confirmDeactivate(context, product),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: Text(l10n.deactivateProduct),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge(BuildContext context, bool isActive) {
    final l10n = AppLocalizations.of(context);
    if (isActive) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gray.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Text(
        l10n.inactiveLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _openProductForm(BuildContext context, Store store, {Product? existingProduct}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductFormPage(
          store: store,
          viewModel: widget.productViewModel,
          existingProduct: existingProduct,
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, Product product) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deactivateProduct),
        content: Text(l10n.deactivateProductConfirm(product.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.no)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.yes)),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.productViewModel.deactivateProduct(product.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.productDeactivatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.productDeactivateFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

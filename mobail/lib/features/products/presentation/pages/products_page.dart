import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../viewmodels/product_viewmodel.dart';
import '../../../../data/models/models.dart';
import 'product_details_page.dart';

class ProductsPage extends StatefulWidget {
  final int? storeId;
  final String? storeName;
  
  const ProductsPage({
    super.key,
    this.storeId,
    this.storeName,
  });
  
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductViewModel _viewModel = ProductViewModel();
  
  @override
  void initState() {
    super.initState();
    _viewModel.loadProducts(storeId: widget.storeId);
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
          if (widget.storeId != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          Expanded(
            child: Text(
              widget.storeName != null ? '${widget.storeName} Products' : 'Products',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.bold,
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
        
        return _buildProductsGrid();
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
              _viewModel.errorMessage ?? 'Failed to load products',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Retry',
              type: AppButtonType.primary,
              onPressed: _viewModel.retry,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No products available',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.storeName != null 
                  ? 'This store has no products yet'
                  : 'Check back later for new products',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: _viewModel.products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_viewModel.products[index]);
      },
    );
  }
  
  Widget _buildProductCard(Product product) {
    final firstImage = product.images.isNotEmpty ? product.images.first : null;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(productId: product.id),
          ),
        );
      },
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
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
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              product.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              product.storeName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (product.variants.isNotEmpty) ...[
              Text(
                product.hasPriceRange
                    ? '${product.lowestPrice.toStringAsFixed(2)} - ${product.highestPrice.toStringAsFixed(2)}'
                    : product.lowestPrice.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

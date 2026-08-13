import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../favorites/presentation/viewmodels/favorite_viewmodel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../../data/models/models.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });
  
  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ProductDetailViewModel _productViewModel = ProductDetailViewModel();
  final CartViewModel _cartViewModel = CartViewModel();
  final FavoriteViewModel _favoriteViewModel = FavoriteViewModel();
  final AuthViewModel _authViewModel = AuthViewModel();
  int _selectedImageIndex = 0;
  int? _selectedVariantIndex;
  bool _isAddingToCart = false;
  bool _isFavorite = false;
  
  @override
  void initState() {
    super.initState();
    _productViewModel.loadProduct(widget.productId);
    _cartViewModel.loadCart();
    _loadFavoriteState();
  }
  
  Future<void> _loadFavoriteState() async {
    if (_authViewModel.isAuthenticated) {
      _isFavorite = await _favoriteViewModel.checkFavorite(widget.productId);
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _productViewModel.dispose();
    _cartViewModel.dispose();
    _favoriteViewModel.dispose();
    _authViewModel.dispose();
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Product Details',
              style: TextStyle(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.error : AppColors.gray,
            ),
            onPressed: _handleFavoriteToggle,
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleFavoriteToggle() async {
    if (!_authViewModel.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    try {
      if (_isFavorite) {
        await _favoriteViewModel.removeFavorite(widget.productId);
        _isFavorite = false;
      } else {
        await _favoriteViewModel.addFavorite(widget.productId);
        _isFavorite = true;
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _productViewModel,
      builder: (context, child) {
        if (_productViewModel.isLoading) {
          return _buildLoadingState();
        }
        
        if (_productViewModel.isError) {
          return _buildErrorState();
        }
        
        if (_productViewModel.product == null) {
          return _buildEmptyState();
        }
        
        return _buildProductDetails(_productViewModel.product!);
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
              _productViewModel.errorMessage ?? 'Failed to load product',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Retry',
              type: AppButtonType.primary,
              onPressed: _productViewModel.retry,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Product not found',
        style: TextStyle(
          color: AppColors.darkNavy,
          fontSize: 18,
        ),
      ),
    );
  }
  
  Future<void> _handleAddToCart() async {
    if (_productViewModel.product == null) return;
    
    final product = _productViewModel.product!;
    
    // Check if variant selection is required
    if (product.variants.isNotEmpty && _selectedVariantIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a variant first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final variantIndex = _selectedVariantIndex ?? 0;
    final variant = product.variants[variantIndex];
    
    if (variant.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This variant is out of stock'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      await _cartViewModel.addItem(
        productId: product.id,
        variantId: variant.id,
        quantity: 1,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add to cart. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }
  
  Widget _buildProductDetails(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(product),
          const SizedBox(height: AppSpacing.lg),
          _buildProductInfo(product),
          const SizedBox(height: AppSpacing.lg),
          _buildStoreInfo(product),
          const SizedBox(height: AppSpacing.lg),
          if (product.variants.isNotEmpty) ...[
            _buildVariantsSection(product),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (product.description != null && product.description!.isNotEmpty) ...[
            _buildDescriptionSection(product),
            const SizedBox(height: AppSpacing.xl),
          ],
          _buildAddToCartButton(),
        ],
      ),
    );
  }
  
  Widget _buildImageSection(Product product) {
    if (product.images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.lightBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: const Icon(
          Icons.inventory_2,
          color: AppColors.primary,
          size: 64,
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            child: Image.network(
              product.images[_selectedImageIndex].imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.inventory_2,
                  color: AppColors.primary,
                  size: 64,
                );
              },
            ),
          ),
        ),
        if (product.images.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedImageIndex == index
                            ? AppColors.primary
                            : AppColors.gray,
                        width: _selectedImageIndex == index ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      child: Image.network(
                        product.images[index].imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory_2,
                            color: AppColors.primary,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (product.variants.isNotEmpty) ...[
          Text(
            product.hasPriceRange
                ? '${product.lowestPrice.toStringAsFixed(2)} - ${product.highestPrice.toStringAsFixed(2)}'
                : product.lowestPrice.toStringAsFixed(2),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildStoreInfo(Product product) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: product.storeLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    child: Image.network(
                      product.storeLogo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.store,
                          color: AppColors.primary,
                          size: 24,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.store,
                    color: AppColors.primary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.storeName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (product.storeAddress != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    product.storeAddress!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVariantsSection(Product product) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Variants',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...product.variants.map((variant) {
            final index = product.variants.indexOf(variant);
            final isSelected = _selectedVariantIndex == index;
            
            return GestureDetector(
              onTap: () {
                if (variant.stock > 0) {
                  setState(() {
                    _selectedVariantIndex = index;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.gray,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (variant.color != null) ...[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _parseColor(variant.color!),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.gray),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    if (variant.size != null) ...[
                      Text(
                        'Size: ${variant.size}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    const Spacer(),
                    Text(
                      variant.price.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (variant.stock > 0) ...[
                      Text(
                        '(${variant.stock} in stock)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Out of stock',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Color _parseColor(String colorString) {
    // Simple color parsing - in production, you'd want more robust color handling
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.gray;
    }
  }
  
  Widget _buildDescriptionSection(Product product) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            product.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddToCartButton() {
    return AppButton(
      text: _isAddingToCart ? 'Adding...' : 'Add to Cart',
      type: AppButtonType.primary,
      isFullWidth: true,
      isLoading: _isAddingToCart,
      onPressed: _isAddingToCart ? null : _handleAddToCart,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../favorites/presentation/viewmodels/favorite_viewmodel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../reviews/presentation/viewmodels/review_viewmodel.dart';
import '../../../reviews/presentation/widgets/review_form_sheet.dart';
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
  final ReviewViewModel _reviewViewModel = ReviewViewModel();
  int _selectedImageIndex = 0;
  int? _selectedVariantIndex;
  bool _isAddingToCart = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _productViewModel.loadProduct(widget.productId);
    _cartViewModel.loadCart();
    _reviewViewModel.loadReviews(widget.productId);
    _initAuthDependentData();
  }

  // Resolves auth state first (checkAuthStatus is async), then loads the
  // pieces of UI that depend on knowing whether the user is logged in:
  // favorite status and review eligibility (purchased + not already reviewed).
  Future<void> _initAuthDependentData() async {
    await _authViewModel.checkAuthStatus();
    if (_authViewModel.isAuthenticated) {
      _isFavorite = await _favoriteViewModel.checkFavorite(widget.productId);
      await _reviewViewModel.checkEligibility(widget.productId);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _productViewModel.dispose();
    _cartViewModel.dispose();
    _favoriteViewModel.dispose();
    _authViewModel.dispose();
    _reviewViewModel.dispose();
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
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.goBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.productDetailsTitle,
              style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
    if (!_authViewModel.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginToFavoritesMessage),
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
          SnackBar(
            content: Text(l10n.updateFavoritesFailed),
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
              _productViewModel.errorMessage ?? l10n.failedToLoadProduct,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.retry,
              type: AppButtonType.primary,
              onPressed: _productViewModel.retry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n.productNotFound,
        style: const TextStyle(
          color: AppColors.darkNavy,
          fontSize: 18,
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    final l10n = AppLocalizations.of(context);
    if (_productViewModel.product == null) return;

    final product = _productViewModel.product!;

    // Check if variant selection is required
    if (product.variants.isNotEmpty && _selectedVariantIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectVariantMessage),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final variantIndex = _selectedVariantIndex ?? 0;
    final variant = product.variants[variantIndex];

    if (variant.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.variantOutOfStockMessage),
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
          SnackBar(
            content: Text(l10n.addedToCartSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on StoreMismatchException {
      // Single-Store Cart Rule: the cart already contains items from a
      // different store. Ask the customer whether to clear it and switch,
      // instead of silently mixing stores or silently failing. Cancelling
      // leaves the cart exactly as it was -- addItem's rejection on the
      // backend never touched it.
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.storeMismatchTitle),
          content: Text(l10n.storeMismatchMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.clearAndSwitchStore),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await _cartViewModel.switchStore(
            productId: product.id,
            variantId: variant.id,
            quantity: 1,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.addedToCartSuccess),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.switchStoreFailed),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.addToCartFailed),
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
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildAddToCartButton(),
          const SizedBox(height: AppSpacing.xl),
          _buildRatingSummarySection(),
          const SizedBox(height: AppSpacing.lg),
          _buildReviewActionSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildReviewsListSection(),
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
                    margin: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
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
        if (product.reviewCount > 0) ...[
          Row(
            children: [
              _buildStaticStars(product.averageRating.round(), size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                product.averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
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
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.availableVariants,
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
                        l10n.sizeValue(variant.size!),
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
                        l10n.stockCount(variant.stock),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    ] else ...[
                      Text(
                        l10n.outOfStock,
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
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.productDescription,
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
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: _isAddingToCart ? l10n.addingToCart : l10n.addToCart,
      type: AppButtonType.primary,
      isFullWidth: true,
      isLoading: _isAddingToCart,
      onPressed: _isAddingToCart ? null : _handleAddToCart,
    );
  }

  // ---------------------------------------------------------------------
  // Reviews & Ratings
  // ---------------------------------------------------------------------

  Widget _buildStaticStars(int rating, {double size = 18}) {
    final clamped = rating.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < clamped ? Icons.star : Icons.star_border,
          color: AppColors.accentOrange,
          size: size,
        );
      }),
    );
  }

  Widget _buildRatingSummarySection() {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _reviewViewModel,
      builder: (context, child) {
        final summary = _reviewViewModel.summary;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reviews,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (summary.reviewCount > 0) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      summary.averageRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStaticStars(summary.averageRating.round()),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.reviewCountLabel(summary.reviewCount),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  l10n.noReviews,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.beFirstToReview,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewActionSection() {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([_authViewModel, _reviewViewModel]),
      builder: (context, child) {
        if (!_authViewModel.isAuthenticated) {
          return AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.loginToReviewMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  text: l10n.login,
                  type: AppButtonType.outline,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        if (!_reviewViewModel.eligibilityChecked) {
          return const SizedBox.shrink();
        }

        if (_reviewViewModel.hasReviewed && _reviewViewModel.existingReview != null) {
          return _buildOwnReviewCard(_reviewViewModel.existingReview!);
        }

        if (_reviewViewModel.canReview) {
          return AppButton(
            text: l10n.writeAReview,
            type: AppButtonType.outline,
            isFullWidth: true,
            onPressed: _openWriteReviewSheet,
          );
        }

        return AppCard(
          child: Text(
            l10n.purchaseRequiredMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.gray,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOwnReviewCard(Review review) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      backgroundColor: AppColors.lightBlue.withOpacity(0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.yourReview,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primary,
                tooltip: l10n.edit,
                onPressed: _reviewViewModel.isSubmitting
                    ? null
                    : () => _openEditReviewSheet(review),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                tooltip: l10n.delete,
                onPressed: _reviewViewModel.isSubmitting
                    ? null
                    : () => _confirmDeleteReview(review),
              ),
            ],
          ),
          _buildStaticStars(review.rating),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              review.comment!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsListSection() {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _reviewViewModel,
      builder: (context, child) {
        if (_reviewViewModel.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (_reviewViewModel.isError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    _reviewViewModel.errorMessage ?? l10n.error,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    text: l10n.retry,
                    type: AppButtonType.outline,
                    onPressed: () => _reviewViewModel.retry(widget.productId),
                  ),
                ],
              ),
            ),
          );
        }

        // Reviews left by other users; the current user's own review (if any)
        // is already shown above in _buildOwnReviewCard, so it's excluded here.
        final currentUserId = _authViewModel.userInfo?['userId'] as int?;
        final otherReviews = _reviewViewModel.reviews
            .where((r) => r.userId != currentUserId)
            .toList();

        if (otherReviews.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: otherReviews.map(_buildReviewCard).toList(),
        );
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildStaticStars(review.rating, size: 16),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              review.comment!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _openWriteReviewSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      builder: (context) {
        return ReviewFormSheet(
          onSubmit: (rating, comment) => _reviewViewModel.submitReview(
            productId: widget.productId,
            rating: rating,
            comment: comment,
          ),
        );
      },
    );

    if (result == true && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reviewSubmittedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _openEditReviewSheet(Review review) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      builder: (context) {
        return ReviewFormSheet(
          existingReview: review,
          onSubmit: (rating, comment) => _reviewViewModel.editReview(
            productId: widget.productId,
            reviewId: review.id,
            rating: rating,
            comment: comment,
          ),
        );
      },
    );

    if (result == true && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reviewUpdatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmDeleteReview(Review review) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteReviewTitle),
          content: Text(l10n.deleteReviewConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l10n.delete,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await _reviewViewModel.removeReview(
      productId: widget.productId,
      reviewId: review.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.reviewDeletedSuccess : l10n.reviewDeleteFailed),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}

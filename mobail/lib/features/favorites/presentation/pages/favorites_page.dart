import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../../../products/presentation/pages/product_details_page.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteViewModel _viewModel = FavoriteViewModel();
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    _authViewModel.checkAuthStatus();
    _loadFavoritesIfAuthenticated();
  }

  Future<void> _loadFavoritesIfAuthenticated() async {
    if (_authViewModel.isAuthenticated) {
      await _viewModel.loadFavorites();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
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
              l10n.myFavorites,
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
      listenable: _authViewModel,
      builder: (context, child) {
        if (!_authViewModel.isAuthenticated) {
          return _buildLoginRequiredState();
        }

        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return _buildLoadingState();
            }

            if (_viewModel.isError) {
              return _buildErrorState();
            }

            if (!_viewModel.hasFavorites) {
              return _buildEmptyState();
            }

            return _buildFavoritesList();
          },
        );
      },
    );
  }

  Widget _buildLoginRequiredState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.loginToViewFavorites,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.loginRequiredFavoritesMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.login,
              type: AppButtonType.primary,
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
      ),
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
              _viewModel.errorMessage ?? l10n.failedToLoadFavorites,
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
              Icons.favorite_border,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noFavorites,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noFavoritesSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _viewModel.favorites.length,
      itemBuilder: (context, index) {
        return _buildFavoriteCard(_viewModel.favorites[index]);
      },
    );
  }

  Widget _buildFavoriteCard(dynamic favorite) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                productId: favorite['product_id'] as int,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: favorite['store_logo'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        child: Image.network(
                          favorite['store_logo'] as String,
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
                      favorite['product_name'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (favorite['store_name'] != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        favorite['store_name'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray,
                            ),
                      ),
                    ],
                    if (favorite['lowest_price'] != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        (favorite['lowest_price'] as num)
                            .toDouble()
                            .toStringAsFixed(2),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.error),
                onPressed: _viewModel.isOperationInProgress
                    ? null
                    : () => _viewModel
                        .removeFavorite(favorite['product_id'] as int),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

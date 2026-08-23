import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/home_viewmodel.dart';
import 'profile_page.dart';
import '../../../stores/presentation/pages/stores_page.dart';
import '../../../stores/presentation/viewmodels/store_viewmodel.dart';
import '../../../../data/models/models.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeViewModel _viewModel = HomeViewModel();
  final StoreViewModel _storeViewModel = StoreViewModel();
  final CartViewModel _cartViewModel = CartViewModel();
  final AuthViewModel _authViewModel = AuthViewModel();
  final CategoryViewModel _categoryViewModel = CategoryViewModel();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _authViewModel.checkAuthStatus();
    _viewModel.loadUserData();
    _storeViewModel.loadStores();
    _cartViewModel.loadCart();
    _categoryViewModel.loadCategories();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _storeViewModel.dispose();
    _cartViewModel.dispose();
    _authViewModel.dispose();
    _categoryViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_selectedIndex) {
      case 0:
        body = _buildHomeContent();
        break;
      case 1:
        body = const StoresPage();
        break;
      case 2:
        body = const ProductsPage();
        break;
      case 3:
        body = const CartPage();
        break;
      case 4:
        body = const ProfilePage();
        break;
      default:
        body = _buildHomeContent();
    }

    return Scaffold(
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrandLogo(
                    size: 40,
                    showBackground: false,
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: AppColors.darkNavy,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.helloUser(_viewModel.userName),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.discoverTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          const SizedBox(height: AppSpacing.lg),
          _buildCategoriesSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildFeaturedSection(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SearchPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 20,
              color: AppColors.gray,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.searchPlaceholder,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return ListenableBuilder(
      listenable: _categoryViewModel,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        if (_categoryViewModel.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.categories,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          );
        }

        if (_categoryViewModel.isError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.categories,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 100,
                child: Center(
                  child: AppButton(
                    text: l10n.retry,
                    type: AppButtonType.secondary,
                    onPressed: _categoryViewModel.retry,
                  ),
                ),
              ),
            ],
          );
        }

        if (!_categoryViewModel.hasCategories) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.categories,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    // Navigate to full categories page
                  },
                  child: Text(l10n.seeAll),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryViewModel.categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(_categoryViewModel.categories[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return Container(
      width: 80,
      margin: const EdgeInsetsDirectional.only(end: AppSpacing.md),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductsPage(
                    categoryId: category.id,
                    categoryName: category.name,
                  ),
                ),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: const Icon(
                Icons.category,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            category.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.darkNavy,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return ListenableBuilder(
      listenable: _storeViewModel,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        if (_storeViewModel.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.featuredStores,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    l10n.seeAllStores,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        }

        if (_storeViewModel.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.featuredStores,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    l10n.seeAllStores,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: const Icon(
                        Icons.store,
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
                            l10n.noStores,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.darkNavy,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.noStoresSubtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final featuredStores = _storeViewModel.stores.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.featuredStores,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const StoresPage()),
                    );
                  },
                  child: Text(
                    l10n.seeAllStores,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredStores.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedStoreCard(featuredStores[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedStoreCard(Store store) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductsPage(
              storeId: store.id,
              storeName: store.name,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsetsDirectional.only(end: AppSpacing.md),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: store.logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        child: Image.network(
                          store.logo!,
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                store.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (store.address != null) ...[
                const SizedBox(height: 4),
                Text(
                  store.address!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return ListenableBuilder(
      listenable: _cartViewModel,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        return BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.gray,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.store_outlined),
              activeIcon: const Icon(Icons.store),
              label: l10n.stores,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: l10n.products,
            ),
            BottomNavigationBarItem(
              icon: _cartViewModel.itemCount > 0
                  ? _buildCartBadge(_cartViewModel.itemCount, Icons.shopping_cart_outlined)
                  : const Icon(Icons.shopping_cart_outlined),
              activeIcon: _cartViewModel.itemCount > 0
                  ? _buildCartBadge(_cartViewModel.itemCount, Icons.shopping_cart)
                  : const Icon(Icons.shopping_cart),
              label: l10n.cart,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outlined),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartBadge(int count, IconData icon) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          PositionedDirectional(
            end: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

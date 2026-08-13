import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
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
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _authViewModel.checkAuthStatus();
    _viewModel.loadUserData();
    _storeViewModel.loadStores();
    _cartViewModel.loadCart();
  }
  
  @override
  void dispose() {
    _viewModel.dispose();
    _storeViewModel.dispose();
    _cartViewModel.dispose();
    _authViewModel.dispose();
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
                'Hello, ${_viewModel.userName}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Discover the best local stores in Aleppo',
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
              'Search products, stores...',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildCategoryItem(_getCategoryName(index));
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryItem(String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Container(
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.gray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  String _getCategoryName(int index) {
    final categories = ['Clothing', 'Shoes', 'Cosmetics', 'Games', 'Electronics', 'More'];
    return categories[index];
  }
  
  Widget _buildFeaturedSection() {
    return ListenableBuilder(
      listenable: _storeViewModel,
      builder: (context, child) {
        if (_storeViewModel.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Stores',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    'See all',
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
                    'Featured Stores',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    'See all',
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
                            'No stores available',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.darkNavy,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Check back later for new stores',
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
                  'Featured Stores',
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
                    'See all',
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
        margin: const EdgeInsets.only(right: AppSpacing.md),
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store),
              label: 'Stores',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: _cartViewModel.itemCount > 0
                  ? _buildCartBadge(_cartViewModel.itemCount, Icons.shopping_cart_outlined)
                  : const Icon(Icons.shopping_cart_outlined),
              activeIcon: _cartViewModel.itemCount > 0
                  ? _buildCartBadge(_cartViewModel.itemCount, Icons.shopping_cart)
                  : const Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
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
          Positioned(
            right: -8,
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

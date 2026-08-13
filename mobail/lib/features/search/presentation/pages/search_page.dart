import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../viewmodels/search_viewmodel.dart';
import '../../../products/presentation/pages/product_details_page.dart';
import '../../../products/presentation/pages/products_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchViewModel _viewModel = SearchViewModel();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }
  
  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchHeader() {
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search products and stores...',
                  hintStyle: const TextStyle(
                    color: AppColors.gray,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                  suffixIcon: _viewModel.hasQuery
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.gray),
                          onPressed: () {
                            _searchController.clear();
                            _viewModel.clearQuery();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (value) {
                  _viewModel.setQuery(value);
                },
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
        
        if (_viewModel.errorMessage != null) {
          return _buildErrorState();
        }
        
        if (!_viewModel.hasQuery) {
          return _buildInitialState();
        }
        
        if (!_viewModel.hasResults) {
          return _buildNoResultsState();
        }
        
        return _buildResults();
      },
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Searching...',
            style: TextStyle(
              color: AppColors.gray,
            ),
          ),
        ],
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
              _viewModel.errorMessage ?? 'Search failed',
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
  
  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search for products and stores',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Enter at least 2 characters to search',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_viewModel.products.isNotEmpty) ...[
            _buildSectionHeader('Products'),
            const SizedBox(height: AppSpacing.md),
            ..._viewModel.products.map((product) {
              return _buildProductResult(product);
            }),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (_viewModel.stores.isNotEmpty) ...[
            _buildSectionHeader('Stores'),
            const SizedBox(height: AppSpacing.md),
            ..._viewModel.stores.map((store) {
              return _buildStoreResult(store);
            }),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppColors.darkNavy,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildProductResult(dynamic productData) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                productId: productData['id'] as int,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: productData['image_path'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        child: Image.network(
                          productData['image_path'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.inventory_2,
                              color: AppColors.primary,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2,
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
                      productData['name'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (productData['store_name'] != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        productData['store_name'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStoreResult(dynamic storeData) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductsPage(
                storeId: storeData['id'] as int,
                storeName: storeData['name'] as String?,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: storeData['logo'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        child: Image.network(
                          storeData['logo'] as String,
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
                      storeData['name'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (storeData['address'] != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        storeData['address'] as String,
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
              const Icon(
                Icons.chevron_right,
                color: AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

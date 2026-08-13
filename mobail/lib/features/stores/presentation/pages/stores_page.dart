import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../viewmodels/store_viewmodel.dart';
import '../../../../data/models/models.dart';
import '../../../products/presentation/pages/products_page.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});
  
  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  final StoreViewModel _viewModel = StoreViewModel();
  
  @override
  void initState() {
    super.initState();
    _viewModel.loadStores();
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
      child: Text(
        'Stores',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.darkNavy,
          fontWeight: FontWeight.bold,
        ),
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
        
        return _buildStoresList();
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
              _viewModel.errorMessage ?? 'Failed to load stores',
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
              Icons.store_outlined,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No stores available',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Check back later for new stores',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStoresList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _viewModel.stores.length,
      itemBuilder: (context, index) {
        return _buildStoreCard(_viewModel.stores[index]);
      },
    );
  }
  
  Widget _buildStoreCard(Store store) {
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
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
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
                            size: 32,
                          );
                        },
                      ),
                    )
                  : const Icon(
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
                    store.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkNavy,
                    ),
                  ),
                  if (store.description != null && store.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      store.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (store.address != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      store.address!,
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/store_owner_viewmodel.dart';
import '../../../../data/models/models.dart';

// Store Owner Dashboard: list of the authenticated owner's own stores, with
// the ability to switch which one every other tab (Dashboard/Products/
// Orders) is scoped to. Fetched via GET /api/stores/mine, which only ever
// returns stores owned by the caller -- there is no id the UI could tamper
// with to reach another owner's store from this list.
class StoreOwnerStoresPage extends StatelessWidget {
  final StoreOwnerViewModel viewModel;

  const StoreOwnerStoresPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        if (viewModel.isLoading && viewModel.myStores.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (viewModel.isError && viewModel.myStores.isEmpty) {
          return _buildErrorState(context);
        }

        if (viewModel.myStores.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: viewModel.loadMyStores,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: viewModel.myStores.length,
            itemBuilder: (context, index) {
              return _buildStoreCard(context, viewModel.myStores[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              viewModel.errorMessage ?? l10n.failedToLoadStores,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.retry,
              type: AppButtonType.primary,
              onPressed: viewModel.retry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 64, color: AppColors.gray),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noOwnedStores,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noOwnedStoresMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, Store store) {
    final l10n = AppLocalizations.of(context);
    final isSelected = viewModel.selectedStore?.id == store.id;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => viewModel.selectStore(store),
      backgroundColor: isSelected ? AppColors.primary.withOpacity(0.06) : AppColors.white,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.store,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.store, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (store.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    store.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (store.status != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _buildStatusBadge(context, store.status!),
                ],
              ],
            ),
          ),
          if (isSelected)
            const Padding(
              padding: EdgeInsetsDirectional.only(start: AppSpacing.sm),
              child: Icon(Icons.check_circle, color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.gray).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Text(
        isActive ? l10n.storeStatusActive : l10n.storeStatusInactive,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? AppColors.success : AppColors.gray,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

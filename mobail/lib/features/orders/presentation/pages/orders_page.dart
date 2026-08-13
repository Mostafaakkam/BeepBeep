import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../viewmodels/order_viewmodel.dart';
import '../../../../data/models/models.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderViewModel _viewModel = OrderViewModel();
  
  @override
  void initState() {
    super.initState();
    _viewModel.loadOrders();
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'My Orders',
              style: TextStyle(
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
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return _buildLoadingState();
        }
        
        if (_viewModel.isError) {
          return _buildErrorState();
        }
        
        if (!_viewModel.hasOrders) {
          return _buildEmptyState();
        }
        
        return _buildOrdersList();
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
              _viewModel.errorMessage ?? 'Failed to load orders',
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
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No orders yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Start shopping to place your first order',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _viewModel.orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_viewModel.orders[index]);
      },
    );
  }
  
  Widget _buildOrderCard(Order order) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _formatDate(order.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.formattedPaymentMethod,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  Text(
                    order.total.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case 'pending':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      case 'confirmed':
      case 'preparing':
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        break;
      case 'shipped':
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        break;
      case 'delivered':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        break;
      default:
        backgroundColor = AppColors.gray.withOpacity(0.2);
        textColor = AppColors.gray;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Text(
        _formatStatus(status),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

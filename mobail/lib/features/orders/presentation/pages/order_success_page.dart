import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';

class OrderSuccessPage extends StatelessWidget {
  final int orderId;
  final double total;
  
  const OrderSuccessPage({
    super.key,
    required this.orderId,
    required this.total,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Order Placed Successfully!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(context, 'Order Number', '#$orderId'),
                    const Divider(),
                    _buildInfoRow(context, 'Payment Method', 'Cash on Delivery'),
                    const Divider(),
                    _buildInfoRow(context, 'Total', total.toStringAsFixed(2)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Thank you for your order!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'View Order',
                type: AppButtonType.primary,
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'Continue Shopping',
                type: AppButtonType.secondary,
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

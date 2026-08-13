import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../pages/order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartViewModel _cartViewModel = CartViewModel();
  final OrderViewModel _orderViewModel = OrderViewModel();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPlacingOrder = false;
  
  @override
  void initState() {
    super.initState();
    _cartViewModel.loadCart();
  }
  
  @override
  void dispose() {
    _cartViewModel.dispose();
    _orderViewModel.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_cartViewModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isPlacingOrder = true;
    });
    
    try {
      final result = await _orderViewModel.createOrder(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(
              orderId: result['orderId'] as int,
              total: (result['total'] as num).toDouble(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
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
              'Checkout',
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
      listenable: _cartViewModel,
      builder: (context, child) {
        if (_cartViewModel.isLoading) {
          return _buildLoadingState();
        }
        
        if (_cartViewModel.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildCheckoutForm();
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
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add some products to checkout',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckoutForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliverySection(),
            const SizedBox(height: AppSpacing.lg),
            _buildOrderSummary(),
            const SizedBox(height: AppSpacing.xl),
            _buildPaymentSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeliverySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name is too short';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+963 900 000 000',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              const phoneRegex = r'^\+?[\d\s-]{10,}$';
              if (!RegExp(phoneRegex).hasMatch(value.trim())) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Delivery Address',
              hintText: 'Enter your delivery address',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your delivery address';
              }
              if (value.trim().length < 10) {
                return 'Address is too short';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._cartViewModel.cart!.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkNavy,
                          ),
                        ),
                        Text(
                          '${item.variant.color ?? ''} ${item.variant.size ?? ''}'.trim(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    item.subtotal.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray,
                ),
              ),
              Text(
                _cartViewModel.subtotal.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray,
                ),
              ),
              Text(
                '5.00',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                (_cartViewModel.total + 5.00).toStringAsFixed(2),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.money,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash on Delivery',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Pay when your order is delivered',
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
      ),
    );
  }
  
  Widget _buildPlaceOrderButton() {
    return AppButton(
      text: _isPlacingOrder ? 'Placing Order...' : 'Place Order',
      type: AppButtonType.primary,
      isFullWidth: true,
      isLoading: _isPlacingOrder,
      onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
    );
  }
}

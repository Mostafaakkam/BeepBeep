import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../../addresses/presentation/viewmodels/address_viewmodel.dart';
import '../../../addresses/presentation/pages/address_form_page.dart';
import '../../../../data/models/models.dart';
import '../pages/order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartViewModel _cartViewModel = CartViewModel();
  final OrderViewModel _orderViewModel = OrderViewModel();
  final AddressViewModel _addressViewModel = AddressViewModel();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPlacingOrder = false;
  AddressModel? _selectedAddress;
  bool _useSavedAddress = false;

  @override
  void initState() {
    super.initState();
    _cartViewModel.loadCart();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    await _addressViewModel.loadAddresses();
    if (_addressViewModel.defaultAddress != null) {
      setState(() {
        _selectedAddress = _addressViewModel.defaultAddress;
        _useSavedAddress = true;
        _populateFormFromAddress(_selectedAddress!);
      });
    }
  }

  void _populateFormFromAddress(AddressModel address) {
    _nameController.text = address.recipientName;
    _phoneController.text = address.phone;
    _addressController.text = address.address;
  }

  @override
  void dispose() {
    _cartViewModel.dispose();
    _orderViewModel.dispose();
    _addressViewModel.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    if (_cartViewModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emptyCart),
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
          SnackBar(
            content: Text(AppLocalizations.of(context).placeOrderFailed),
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
              l10n.checkout,
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
    final l10n = AppLocalizations.of(context);
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
              l10n.emptyCart,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.emptyCartCheckoutSubtitle,
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
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deliveryInformation,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Saved address section
          ListenableBuilder(
            listenable: _addressViewModel,
            builder: (context, child) {
              if (_addressViewModel.hasAddresses) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _useSavedAddress,
                          onChanged: (value) {
                            setState(() {
                              _useSavedAddress = value ?? false;
                              if (_useSavedAddress &&
                                  _selectedAddress != null) {
                                _populateFormFromAddress(_selectedAddress!);
                              }
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text(
                          l10n.useSavedAddress,
                          style: const TextStyle(
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ],
                    ),
                    if (_useSavedAddress) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildAddressSelector(),
                    ],
                    const SizedBox(height: AppSpacing.md),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Manual address form
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              hintText: l10n.nameHint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterName;
              }
              if (value.trim().length < 2) {
                return l10n.nameTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.phoneNumber,
              hintText: l10n.phoneHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterPhone;
              }
              const phoneRegex = r'^\+?[\d\s-]{10,}$';
              if (!RegExp(phoneRegex).hasMatch(value.trim())) {
                return l10n.invalidPhoneNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: l10n.deliveryAddress,
              hintText: l10n.deliveryAddressHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterAddress;
              }
              if (value.trim().length < 10) {
                return l10n.addressTooShort;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelector() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_addressViewModel.addresses.length > 1)
          DropdownButtonFormField<AddressModel>(
            value: _selectedAddress,
            decoration: InputDecoration(
              labelText: l10n.selectAddress,
              border: const OutlineInputBorder(),
            ),
            items: _addressViewModel.addresses.map((address) {
              return DropdownMenuItem<AddressModel>(
                value: address,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      address.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (address) {
              setState(() {
                _selectedAddress = address;
                if (address != null) {
                  _populateFormFromAddress(address);
                }
              });
            },
          ),
        if (_addressViewModel.addresses.length == 1 && _selectedAddress != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAddress!.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        _selectedAddress!.address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddressFormPage(),
              ),
            );
            if (result != null && result is AddressModel) {
              await _addressViewModel.addAddress(result);
              await _loadAddresses();
            }
          },
          icon: const Icon(Icons.add, size: 16),
          label: Text(l10n.addNewAddress),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderSummary,
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.darkNavy,
                                  ),
                        ),
                        Text(
                          '${item.variant.color ?? ''} ${item.variant.size ?? ''}'
                              .trim(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.gray,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.quantity(item.quantity),
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
                l10n.subtotal,
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
                l10n.deliveryFee,
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
                l10n.total,
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
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentMethod,
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
                        l10n.cashOnDelivery,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.payOnDeliveryDescription,
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
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: _isPlacingOrder ? l10n.placingOrder : l10n.placeOrder,
      type: AppButtonType.primary,
      isFullWidth: true,
      isLoading: _isPlacingOrder,
      onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
    );
  }
}

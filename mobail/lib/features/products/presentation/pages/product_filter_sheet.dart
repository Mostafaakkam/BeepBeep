import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';

class ProductFilterSheet extends StatefulWidget {
  final ProductFilter initialFilter;
  final Function(ProductFilter) onApply;

  const ProductFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late ProductFilter _filter;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    if (_filter.minPrice != null) {
      _minPriceController.text = _filter.minPrice!.toStringAsFixed(0);
    }
    if (_filter.maxPrice != null) {
      _maxPriceController.text = _filter.maxPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filterProducts,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filter = _filter.clearFilters();
                    _minPriceController.clear();
                    _maxPriceController.clear();
                  });
                },
                child: Text(l10n.clearAll),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range
                    Text(
                      l10n.priceRangeLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minPriceController,
                            decoration: InputDecoration(
                              labelText: l10n.minPrice,
                              hintText: l10n.zeroPlaceholder,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                final price = double.tryParse(value);
                                _filter = _filter.copyWith(minPrice: price);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Text('-'),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextFormField(
                            controller: _maxPriceController,
                            decoration: InputDecoration(
                              labelText: l10n.maxPrice,
                              hintText: l10n.anyHint,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                final price = double.tryParse(value);
                                _filter = _filter.copyWith(maxPrice: price);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Availability
                    Row(
                      children: [
                        Checkbox(
                          value: _filter.inStock,
                          onChanged: (value) {
                            setState(() {
                              _filter = _filter.copyWith(inStock: value ?? false);
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.inStockOnly,
                          style: const TextStyle(
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Sorting
                    Text(
                      l10n.sortBy,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: _filter.sortBy,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'newest', child: Text(l10n.newest)),
                        DropdownMenuItem(value: 'price_asc', child: Text(l10n.priceAsc)),
                        DropdownMenuItem(value: 'price_desc', child: Text(l10n.priceDesc)),
                        DropdownMenuItem(value: 'name_asc', child: Text(l10n.nameAsc)),
                        DropdownMenuItem(value: 'name_desc', child: Text(l10n.nameDesc)),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(sortBy: value ?? 'newest');
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: l10n.cancel,
                  type: AppButtonType.secondary,
                  isFullWidth: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  text: l10n.apply,
                  type: AppButtonType.primary,
                  isFullWidth: true,
                  onPressed: () {
                    widget.onApply(_filter);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

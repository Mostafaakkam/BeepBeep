import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';
import '../../../../data/repositories/category_repository.dart';
import '../viewmodels/owner_product_viewmodel.dart';

class _VariantRow {
  final int? id; // null means "new variant, not yet saved"
  final TextEditingController colorController;
  final TextEditingController sizeController;
  final TextEditingController priceController;
  final TextEditingController stockController;

  _VariantRow({
    this.id,
    String color = '',
    String size = '',
    String price = '',
    String stock = '',
  })  : colorController = TextEditingController(text: color),
        sizeController = TextEditingController(text: size),
        priceController = TextEditingController(text: price),
        stockController = TextEditingController(text: stock);

  void dispose() {
    colorController.dispose();
    sizeController.dispose();
    priceController.dispose();
    stockController.dispose();
  }
}

// Store Owner Dashboard: create/edit form for one product in the selected
// store. Only manages fields that already exist in the schema
// (products.name/description/category_id, product_variants.color/size/
// price/stock, product_images.image_path) -- no new fields invented.
//
// Editing is deliberately narrower than creating: existing variants are
// updated in place and new ones can be appended, but none can be removed
// here (the backend never deletes a variant row through this form -- see
// productRepository.update's own comments, this avoids breaking a FK from
// cart_items/order_items). Images are only set at creation time; the
// update endpoint does not touch product_images, so no image editor is
// shown when editing (showing one that silently did nothing would be
// misleading).
class ProductFormPage extends StatefulWidget {
  final Store store;
  final Product? existingProduct;
  final OwnerProductViewModel viewModel;

  const ProductFormPage({
    super.key,
    required this.store,
    required this.viewModel,
    this.existingProduct,
  });

  bool get isEditing => existingProduct != null;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imagesController = TextEditingController();

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  final List<_VariantRow> _variantRows = [];

  bool _isSaving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final product = widget.existingProduct;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _selectedCategoryId = product.categoryId;
      for (final v in product.variants) {
        _variantRows.add(_VariantRow(
          id: v.id,
          color: v.color ?? '',
          size: v.size ?? '',
          price: v.price.toString(),
          stock: v.stock.toString(),
        ));
      }
    }
    if (_variantRows.isEmpty) {
      _variantRows.add(_VariantRow());
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _categoryRepository.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _imagesController.dispose();
    for (final row in _variantRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addVariantRow() {
    setState(() {
      _variantRows.add(_VariantRow());
    });
  }

  void _removeVariantRow(_VariantRow row) {
    // Only ever removable while still unsaved/new (no id) -- an existing
    // variant can be retired by setting its stock to 0, never deleted here.
    if (row.id != null) return;
    setState(() {
      _variantRows.remove(row);
      row.dispose();
    });
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _formError = null);

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _formError = l10n.productNameRequired);
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _formError = l10n.pleaseSelectCategory);
      return;
    }
    if (_variantRows.isEmpty) {
      setState(() => _formError = l10n.atLeastOneVariantRequired);
      return;
    }

    final variants = <Map<String, dynamic>>[];
    for (final row in _variantRows) {
      final price = double.tryParse(row.priceController.text.trim());
      final stock = int.tryParse(row.stockController.text.trim());
      if (price == null || price <= 0) {
        setState(() => _formError = l10n.invalidVariantPrice);
        return;
      }
      if (stock == null || stock < 0) {
        setState(() => _formError = l10n.invalidVariantStock);
        return;
      }
      variants.add({
        if (row.id != null) 'id': row.id,
        'color': row.colorController.text.trim().isEmpty ? null : row.colorController.text.trim(),
        'size': row.sizeController.text.trim().isEmpty ? null : row.sizeController.text.trim(),
        'price': price,
        'stock': stock,
      });
    }

    final images = _imagesController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    setState(() => _isSaving = true);

    try {
      if (widget.isEditing) {
        await widget.viewModel.updateProduct(
          productId: widget.existingProduct!.id,
          name: name,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          variants: variants,
        );
      } else {
        await widget.viewModel.createProduct(
          storeId: widget.store.id,
          name: name,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          variants: variants,
          images: images,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? l10n.productUpdatedSuccess : l10n.productCreatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = widget.isEditing ? l10n.productUpdateFailed : l10n.productCreateFailed;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(child: _buildForm(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.gray.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.goBack,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: Text(
              widget.isEditing ? l10n.editProduct : l10n.addProduct,
              style: const TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.storeLabel(widget.store.name),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: l10n.productName,
            hint: l10n.productName,
            controller: _nameController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: l10n.productDescription,
            hint: l10n.productDescription,
            controller: _descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCategoryDropdown(l10n),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.availableVariants,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy),
          ),
          if (widget.isEditing) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.existingVariantsCannotBeRemoved,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ..._variantRows.map((row) => _buildVariantRow(l10n, row)),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _addVariantRow,
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: Text(l10n.addVariant, style: const TextStyle(color: AppColors.primary)),
            ),
          ),
          if (!widget.isEditing) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.images,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.imageUrlsHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _imagesController,
              hint: 'https://example.com/image.jpg',
              maxLines: 3,
            ),
          ],
          if (_formError != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _formError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: l10n.saveProduct,
            type: AppButtonType.primary,
            isFullWidth: true,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _handleSave,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations l10n) {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkNavy),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.inputPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedCategoryId,
              hint: Text(l10n.selectCategory),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVariantRow(AppLocalizations l10n, _VariantRow row) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.color,
                  hint: l10n.color,
                  controller: row.colorController,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.size,
                  hint: l10n.size,
                  controller: row.sizeController,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.price,
                  hint: '0.00',
                  controller: row.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.stock,
                  hint: '0',
                  controller: row.stockController,
                  keyboardType: TextInputType.number,
                ),
              ),
              if (row.id == null) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () => _removeVariantRow(row),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

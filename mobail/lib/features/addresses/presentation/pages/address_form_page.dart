import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';

class AddressFormPage extends StatefulWidget {
  final AddressModel? address; // If null, it's add mode

  const AddressFormPage({
    super.key,
    this.address,
  });

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _cityController.text = widget.address!.city;
      _areaController.text = widget.address!.area ?? '';
      _detailsController.text = widget.address!.details ?? '';
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _areaController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = AddressModel(
        id: widget.address?.id ?? 0,
        userId: widget.address?.userId ?? 0,
        city: _cityController.text.trim(),
        area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        details: _detailsController.text.trim(),
        isDefault: _isDefault,
      );

      setState(() {
        _isSaving = true;
      });

      Navigator.of(context).pop(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.address != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isEditMode),
            Expanded(
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditMode) {
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
              isEditMode ? l10n.editAddress : l10n.addAddress,
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

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: l10n.city,
                hintText: l10n.cityHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.cityRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: l10n.area,
                hintText: l10n.areaHint,
                border: const OutlineInputBorder(),
              ),
              // Area is optional (nullable on the live schema) -- no validator.
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _detailsController,
              decoration: InputDecoration(
                labelText: l10n.addressDetails,
                hintText: l10n.addressDetailsHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.addressDetailsRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Checkbox(
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.setAsDefaultAddress,
                  style: const TextStyle(
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: _isSaving ? l10n.saving : l10n.saveAddressButton,
              type: AppButtonType.primary,
              isFullWidth: true,
              onPressed: _isSaving ? null : _saveAddress,
            ),
          ],
        ),
      ),
    );
  }
}

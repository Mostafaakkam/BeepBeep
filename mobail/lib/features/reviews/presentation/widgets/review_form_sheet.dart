import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';

/// Bottom sheet form for submitting a new review or editing an existing one.
/// [onSubmit] performs the actual API call (create or update, depending on
/// which the caller wired up) and returns whether it succeeded.
class ReviewFormSheet extends StatefulWidget {
  final Review? existingReview;
  final Future<bool> Function(int rating, String? comment) onSubmit;

  const ReviewFormSheet({
    super.key,
    this.existingReview,
    required this.onSubmit,
  });

  @override
  State<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<ReviewFormSheet> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;
  String? _validationError;

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController =
        TextEditingController(text: widget.existingReview?.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context);

    if (_rating < 1 || _rating > 5) {
      setState(() {
        _validationError = l10n.pleaseSelectRating;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationError = null;
    });

    final comment = _commentController.text.trim();
    final success =
        await widget.onSubmit(_rating, comment.isEmpty ? null : comment);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _validationError = l10n.reviewSubmitFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
              ),
            ),
          ),
          Text(
            _isEditing ? l10n.editYourReview : l10n.writeAReview,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.yourRating,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _rating = starValue;
                          _validationError = null;
                        });
                      },
                icon: Icon(
                  starValue <= _rating ? Icons.star : Icons.star_border,
                  color: AppColors.accentOrange,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l10n.yourReviewOptional,
            hint: l10n.reviewCommentHint,
            controller: _commentController,
            maxLines: 4,
            maxLength: 1000,
            enabled: !_isSubmitting,
          ),
          if (_validationError != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _validationError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: _isSubmitting
                ? l10n.saving
                : (_isEditing ? l10n.saveChanges : l10n.submitReview),
            type: AppButtonType.primary,
            isFullWidth: true,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}

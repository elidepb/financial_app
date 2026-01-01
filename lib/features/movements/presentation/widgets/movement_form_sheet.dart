import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/form_action_buttons.dart';
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movement_form_data.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_header.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_container.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_fields.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/category_dropdown.dart';

class MovementFormSheet extends StatefulWidget {
  final String? movementId;
  final MovementType? initialType;
  final VoidCallback? onSaved;

  const MovementFormSheet({
    super.key,
    this.movementId,
    this.initialType,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    String? movementId,
    MovementType? initialType,
    VoidCallback? onSaved,
  }) {
    if (!context.mounted) {
      return Future.value();
    }
    
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: MovementFormSheet(
            movementId: movementId,
            initialType: initialType,
            onSaved: onSaved,
          ),
        ),
      );
    } else {
      return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: MovementFormSheet(
                movementId: movementId,
                initialType: initialType,
                onSaved: onSaved,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<MovementFormSheet> createState() => _MovementFormSheetState();
}

class _MovementFormSheetState extends State<MovementFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  MovementType _type = MovementType.expense;
  double? _amountValue;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _description = '';
  String _notes = '';
  bool _isSaving = false;

  final List<CategoryOption> _categories = MovementFormDataHelper.getDefaultCategories();

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _type = widget.initialType!;
    }
    if (widget.movementId != null) {
      _loadMovementData();
    }
  }

  void _loadMovementData() {
    final mockMovements = MovementFormDataHelper.getMockMovements();
    final movement = mockMovements.firstWhere(
      (m) => m['id'] == widget.movementId,
      orElse: () => {},
    );
    
    if (movement.isNotEmpty) {
      setState(() {
        _type = movement['isExpense'] == true 
            ? MovementType.expense 
            : MovementType.income;
        _amountValue = (movement['amount'] as num).abs().toDouble();
        _description = movement['description'] ?? '';
        _selectedCategoryId = MovementFormDataHelper.findCategoryIdByName(
          movement['category'] ?? '',
          _categories,
        );
        _selectedDate = movement['date'] as DateTime? ?? DateTime.now();
        _notes = movement['notes'] ?? '';
      });
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    final content = MovementFormContainer(
      isMobile: isMobile,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MovementFormHeader(
            isMobile: isMobile,
            isEditing: widget.movementId != null,
            onClose: () => Navigator.of(context).pop(),
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: MovementFormFields(
                  type: _type,
                  amountValue: _amountValue,
                  description: _description,
                  selectedCategoryId: _selectedCategoryId,
                  selectedDate: _selectedDate,
                  notes: _notes,
                  categories: _categories,
                  onTypeChanged: (type) {
                    setState(() {
                      _type = type;
                      _selectedCategoryId = null;
                    });
                  },
                  onAmountChanged: (value) {
                    setState(() {
                      _amountValue = value;
                    });
                  },
                  onDescriptionChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  onCategoryChanged: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  onNotesChanged: (value) {
                    setState(() {
                      _notes = value;
                    });
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: FormActionButtons(
              onSave: _handleSave,
              isSaving: _isSaving,
              isSaveEnabled: _amountValue != null &&
                  _amountValue! > 0 &&
                  _description.isNotEmpty &&
                  _selectedCategoryId != null,
              saveLabel: widget.movementId == null ? 'Guardar' : 'Actualizar',
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          _scrollController.addListener(() {
            scrollController.jumpTo(_scrollController.offset);
          });
          return content;
        },
      );
    } else {
      return content;
    }
  }
}


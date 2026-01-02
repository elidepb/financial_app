import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/form_action_buttons.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_header.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_container.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_fields.dart';
import 'package:app_gestor_financiero/features/movements/data/providers/movements_providers.dart';
import 'package:app_gestor_financiero/features/movements/data/providers/movement_detail_provider.dart';
import 'package:app_gestor_financiero/features/categories/data/providers/categories_providers.dart';
import 'package:app_gestor_financiero/database/mappers/category_mapper.dart';
import 'package:app_gestor_financiero/database/app_database.dart';

class MovementFormSheet extends ConsumerStatefulWidget {
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
  ConsumerState<MovementFormSheet> createState() => _MovementFormSheetState();
}

class _MovementFormSheetState extends ConsumerState<MovementFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  MovementType _type = MovementType.expense;
  double? _amountValue;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _description = '';
  String _notes = '';
  bool _isSaving = false;
  String? _currentMovementId;
  int _formKeyVersion = 0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialType != null) {
      _type = widget.initialType!;
    }
    _currentMovementId = widget.movementId;
    
    // Resetear valores si no hay movementId (modo creación)
    if (widget.movementId == null) {
      _resetFormToDefaults();
    }
  }

  void _resetFormToDefaults() {
    _amountValue = null;
    _description = '';
    _selectedCategoryId = null;
    _selectedDate = DateTime.now();
    _notes = '';
    if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void didUpdateWidget(MovementFormSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió el movementId, resetear y cargar nuevos datos
    if (oldWidget.movementId != widget.movementId) {
      _currentMovementId = widget.movementId;
      if (widget.movementId == null) {
        // Modo creación: resetear a valores por defecto
        _resetFormToDefaults();
        _formKeyVersion++;
      } else {
        // Modo edición: resetear y esperar a que se carguen los datos
        _resetFormToDefaults();
        _formKeyVersion++;
      }
    }
    // Si cambió el initialType y no hay movementId, actualizar el tipo
    if (oldWidget.initialType != widget.initialType && widget.movementId == null) {
      if (widget.initialType != null) {
        _type = widget.initialType!;
      }
    }
  }

  void _loadMovementDataIfNeeded(Movement movement) {
    if (!mounted || widget.movementId != _currentMovementId) {
      return;
    }
    
    // Verificar si los datos ya están cargados comparando valores
    final needsUpdate = _amountValue != movement.amount ||
        _description != movement.description ||
        _selectedCategoryId != movement.categoryId ||
        _selectedDate != movement.date ||
        _notes != (movement.notes ?? '') ||
        _type != (movement.type == 'expense' ? MovementType.expense : MovementType.income);
    
    if (needsUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.movementId == _currentMovementId) {
          _loadMovementData(movement);
        }
      });
    }
  }

  void _loadMovementData(Movement movement) {
    if (!mounted || widget.movementId != _currentMovementId) {
      return;
    }
    
    setState(() {
      _type = movement.type == 'expense' ? MovementType.expense : MovementType.income;
      _amountValue = movement.amount;
      _description = movement.description;
      _selectedCategoryId = movement.categoryId;
      _selectedDate = movement.date;
      _notes = movement.notes ?? '';
      _formKeyVersion++;
    });
  }

  List<CategoryOption> _getCategories() {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type == MovementType.expense ? 'expense' : 'income'));
    return categoriesAsync.when(
      data: (categories) => CategoryMapper.toCategoryOptions(categories),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    if (_amountValue == null || _selectedCategoryId == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    HapticFeedback.mediumImpact();

    try {
      if (widget.movementId != null) {
        await ref.read(updateMovementProvider(UpdateMovementParams(
          id: widget.movementId!,
          amount: _amountValue!,
          description: _description,
          categoryId: _selectedCategoryId!,
          date: _selectedDate,
          type: _type == MovementType.expense ? 'expense' : 'income',
          notes: _notes.isEmpty ? null : _notes,
        )).future);
      } else {
        await ref.read(createMovementProvider(CreateMovementParams(
          amount: _amountValue!,
          description: _description,
          categoryId: _selectedCategoryId!,
          date: _selectedDate,
          type: _type == MovementType.expense ? 'expense' : 'income',
          notes: _notes.isEmpty ? null : _notes,
        )).future);
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop();
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    // Observar y escuchar cambios en el provider del movimiento
    if (widget.movementId != null && widget.movementId == _currentMovementId) {
      // Observar el provider para mantener la reactividad
      final movementAsync = ref.watch(movementDetailProvider(widget.movementId!));
      
      // Escuchar cambios en el provider (se ejecuta cuando el estado cambia)
      // Esto maneja tanto el caso inicial como los cambios posteriores
      ref.listen<AsyncValue<Movement?>>(
        movementDetailProvider(widget.movementId!),
        (previous, next) {
          // Solo procesar si el estado cambió de loading a data, o si hay datos nuevos
          if (previous?.isLoading == true || previous?.value != next.value) {
            next.whenData((movement) {
              if (movement != null && mounted && widget.movementId == _currentMovementId) {
                _loadMovementDataIfNeeded(movement);
              }
            });
          }
        },
      );
      
      // Cargar datos si ya están disponibles en el primer build (caso cuando el provider ya tiene datos en caché)
      if (movementAsync.hasValue && movementAsync.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.movementId == _currentMovementId) {
            _loadMovementDataIfNeeded(movementAsync.value!);
          }
        });
      }
    }

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
                  key: ValueKey('form_fields_$_formKeyVersion'),
                  type: _type,
                  amountValue: _amountValue,
                  description: _description,
                  selectedCategoryId: _selectedCategoryId,
                  selectedDate: _selectedDate,
                  notes: _notes,
                  categories: _getCategories(),
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


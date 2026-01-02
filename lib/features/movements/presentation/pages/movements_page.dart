import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/core/widgets/custom_bottom_nav.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/custom_fab.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/sliver_search_appbar.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/filter_chip_bar.dart' show FilterChipBar, MovementFilterChip;
import 'package:app_gestor_financiero/features/movements/presentation/widgets/empty_state_illustrator.dart';
import 'package:app_gestor_financiero/features/movements/presentation/providers/share_providers.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/confirmation_dialog.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movement_filters_helper.dart';
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movement_grouping_helper.dart';
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movements_actions_helper.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/filter_bottom_sheet.dart';
import 'package:app_gestor_financiero/features/movements/data/providers/movements_providers.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_sheet.dart';

class MovementsPage extends ConsumerStatefulWidget {
  final String? highlightMovementId;
  final Map<String, String> filters;

  const MovementsPage({
    super.key,
    this.highlightMovementId,
    this.filters = const {},
  });

  @override
  ConsumerState<MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends ConsumerState<MovementsPage> {
  String _searchQuery = '';
  final Map<String, MovementFilterChip> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    if (widget.highlightMovementId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToHighlighted();
      });
    }
  }

  void _initializeFilters() {
    widget.filters.forEach((key, value) {
      _activeFilters[key] = MovementFilterChip(
        id: key,
        label: '$key: $value',
        icon: MovementFiltersHelper.getFilterIcon(key),
        color: MovementFiltersHelper.getFilterColor(key),
      );
    });
  }

  List<MovementItem> _applyFilters(List<MovementItem> allMovements) {
    var filtered = List<MovementItem>.from(allMovements);
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((movement) {
        return movement.description
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterRemoved(String filterId) {
    setState(() {
      _activeFilters.remove(filterId);
    });
  }

  void _onAddFilter() {
    FilterBottomSheet.show(context);
  }

  void _onExportTap() async {
    final movementsAsync = ref.read(movementsStreamProvider);
    movementsAsync.whenData((movements) async {
      try {
        final exportUseCase = ref.read(exportMovementsUseCaseProvider);
        final filteredMovements = _applyFilters(movements);
        final formattedContent = exportUseCase(filteredMovements);
        final shareService = ref.read(shareServiceProvider);
        await shareService.shareText(
          content: formattedContent,
          subject: 'Exportación de Movimientos',
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al exportar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _onItemTap(String id) {
    HapticFeedback.lightImpact();
    _onItemEdit(id);
  }

  void _onItemEdit(String id) {
    MovementFormSheet.show(
      context,
      movementId: id,
      onSaved: () {
        if (mounted) {
          MovementsActionsHelper.showSuccessSnackBar(
            context,
            'Movimiento actualizado',
          );
        }
      },
    );
  }

  void _onItemDelete(String id) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Eliminar Movimiento',
      message: '¿Estás seguro de que deseas eliminar este movimiento?\n\nEsta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      try {
        await ref.read(deleteMovementProvider(id).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Movimiento eliminado'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _scrollToHighlighted() {}

  List<Widget> _buildGroupedSlivers(List<MovementItem> movements) {
    final filteredMovements = _applyFilters(movements);
    return MovementGroupingHelper.buildGroupedSlivers(
      movements: filteredMovements,
      highlightMovementId: widget.highlightMovementId,
      onItemTap: _onItemTap,
      onItemEdit: _onItemEdit,
      onItemDelete: _onItemDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final movementsAsync = ref.watch(movementsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: movementsAsync.when(
                data: (movements) {
                  final filteredMovements = _applyFilters(movements);
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(movementsStreamProvider);
                    },
                    color: const Color(0xFF7E57C2),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverSearchAppBar(
                          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                          onSearchChanged: _onSearchChanged,
                          onFilterTap: _onAddFilter,
                          onExportTap: _onExportTap,
                        ),
                        if (_activeFilters.isNotEmpty)
                          SliverToBoxAdapter(
                            child: FilterChipBar(
                              filters: _activeFilters.values.toList(),
                              onFilterRemoved: _onFilterRemoved,
                              onAddFilter: _onAddFilter,
                            ),
                          ),
                        if (filteredMovements.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyStateIllustrator(
                              title: 'No hay movimientos',
                              subtitle: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                  ? 'No se encontraron movimientos con los filtros aplicados'
                                  : 'Agrega tu primer movimiento para comenzar',
                              actionLabel: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                  ? null
                                  : 'Agregar Movimiento',
                              onAction: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                  ? null
                                  : () {},
                            ),
                          )
                        else
                          ..._buildGroupedSlivers(movements),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(movementsStreamProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Builder(
                builder: (fabContext) {
                  return CustomFAB(
                    onExpensePressed: () {
                      if (!mounted || !fabContext.mounted) return;
                      
                      MovementFormSheet.show(
                        fabContext,
                        initialType: MovementType.expense,
                        onSaved: () {
                          if (fabContext.mounted) {
                            MovementsActionsHelper.showSuccessSnackBar(
                              fabContext,
                              'Gasto creado exitosamente',
                            );
                          }
                        },
                      );
                    },
                    onIncomePressed: () {
                      if (!mounted || !fabContext.mounted) return;
                      
                      MovementFormSheet.show(
                        fabContext,
                        initialType: MovementType.income,
                        onSaved: () {
                          if (fabContext.mounted) {
                            MovementsActionsHelper.showSuccessSnackBar(
                              fabContext,
                              'Ingreso creado exitosamente',
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

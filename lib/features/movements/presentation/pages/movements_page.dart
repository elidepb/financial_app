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
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movements_mock_data.dart';
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movement_filters_helper.dart';
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movement_grouping_helper.dart';
import 'package:app_gestor_financiero/features/movements/presentation/helpers/movements_actions_helper.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/filter_bottom_sheet.dart';

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
  List<MovementItem> _allMovements = [];
  List<MovementItem> _filteredMovements = [];

  @override
  void initState() {
    super.initState();
    _loadMovements();
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

  void _loadMovements() {
    setState(() {
      _allMovements = MovementsMockData.getSampleMovements();
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = List<MovementItem>.from(_allMovements);
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((movement) {
        return movement.description
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    filtered.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _filteredMovements = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onFilterRemoved(String filterId) {
    setState(() {
      _activeFilters.remove(filterId);
    });
    _applyFilters();
  }

  void _onAddFilter() {
    FilterBottomSheet.show(context);
  }

  void _onExportTap() async {
    try {
      final exportUseCase = ref.read(exportMovementsUseCaseProvider);
      final formattedContent = exportUseCase(_filteredMovements);
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
  }

  void _onItemTap(String id) {
    HapticFeedback.lightImpact();
    _onItemEdit(id);
  }

  void _onItemEdit(String id) {
    final movement = _allMovements.firstWhere((m) => m.id == id);
    
    MovementsActionsHelper.showEditForm(
      context,
      movement,
      () {
        _loadMovements();
        MovementsActionsHelper.showSuccessSnackBar(
          context,
          'Movimiento actualizado',
        );
      },
    );
  }

  void _onItemDelete(String id) {
    final movement = _allMovements.firstWhere((m) => m.id == id);
    
    ConfirmationDialog.show(
      context,
      title: 'Eliminar Movimiento',
      message: '¿Estás seguro de que deseas eliminar "${movement.description}"?\n\nEsta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        HapticFeedback.mediumImpact();
        setState(() {
          _allMovements.removeWhere((m) => m.id == id);
        });
        _applyFilters();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Movimiento eliminado'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _scrollToHighlighted() {}

  void _onRefresh() {
    _loadMovements();
  }

  List<Widget> _buildGroupedSlivers() {
    return MovementGroupingHelper.buildGroupedSlivers(
      movements: _filteredMovements,
      highlightMovementId: widget.highlightMovementId,
      onItemTap: _onItemTap,
      onItemEdit: _onItemEdit,
      onItemDelete: _onItemDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () async {
                  _onRefresh();
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
                    if (_filteredMovements.isEmpty)
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
                      ..._buildGroupedSlivers(),
                  ],
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
                      
                      MovementsActionsHelper.showCreateForm(
                        fabContext,
                        MovementType.expense,
                        () {
                          _loadMovements();
                          MovementsActionsHelper.showSuccessSnackBar(
                            fabContext,
                            'Gasto creado exitosamente',
                          );
                        },
                      );
                    },
                    onIncomePressed: () {
                      if (!mounted || !fabContext.mounted) return;
                      
                      MovementsActionsHelper.showCreateForm(
                        fabContext,
                        MovementType.income,
                        () {
                          _loadMovements();
                          MovementsActionsHelper.showSuccessSnackBar(
                            fabContext,
                            'Ingreso creado exitosamente',
                          );
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
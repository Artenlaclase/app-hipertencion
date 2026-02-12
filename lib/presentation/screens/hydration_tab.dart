import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/hydration.dart';
import '../../domain/usecases/get_hydration_records.dart';
import '../../domain/usecases/add_hydration_record.dart';
import '../../domain/usecases/delete_hydration_record.dart';
// import '../widgets/add_hydration_dialog.dart';

class HydrationTab extends StatefulWidget {
  const HydrationTab({super.key});

  @override
  State<HydrationTab> createState() => _HydrationTabState();
}

class _HydrationTabState extends State<HydrationTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hidratación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(context),
            const SizedBox(height: 24),
            _buildQuickAddSection(context),
            const SizedBox(height: 24),
            _buildTypeSummary(context),
            const SizedBox(height: 24),
            ..._todayRecords.asMap().entries.map(
              (entry) => _buildRecordTile(context, entry.value, entry.key),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  final List<HydrationRecord> _records = [];
  final int _dailyGoalMl = 2000;
  String? _errorMessage;
  Map<LiquidType, int> get _todaySummaryByType {
    final summary = <LiquidType, int>{};
    for (final r in _todayRecords) {
      summary[r.liquidType] = (summary[r.liquidType] ?? 0) + r.amountMl;
    }
    return summary;
  }

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {});

    final getRecords = GetIt.instance<GetHydrationRecords>();
    final result = await getRecords(DateTime.now());

    result.fold(
      (failure) {
        final isAuthError =
            failure.message.toLowerCase().contains('auth') ||
            failure.message.toLowerCase().contains('token') ||
            failure.message.toLowerCase().contains('sesión');
        setState(() {
          if (isAuthError) {
            _errorMessage =
                'Error de autenticación. Por favor, vuelve a iniciar sesión.';
          } else {
            _errorMessage = failure.message;
          }
        });
      },
      (records) {
        setState(() {
          _records.clear();
          _records.addAll(records);
          _errorMessage = null;
        });
      },
    );
  }

  int get _totalMl => _records
      .where((r) => _isToday(r.timestamp))
      .fold(0, (sum, r) => sum + r.amountMl);

  double get _progress => _totalMl / _dailyGoalMl;
  int get _glassesCount => (_totalMl / 250).floor();

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  Future<void> _addRecord(HydrationRecord record) async {
    final addRecord = GetIt.instance<AddHydrationRecord>();
    final result = await addRecord(record);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      (saved) {
        setState(() {
          _records.add(saved);
        });
      },
    );
  }

  Future<void> _deleteRecord(int index) async {
    final todayRecords = _todayRecords;
    if (index >= todayRecords.length) return;
    final record = todayRecords[index];

    final deleteRecord = GetIt.instance<DeleteHydrationRecord>();
    final result = await deleteRecord(record.id);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      (_) {
        setState(() {
          _records.removeWhere((r) => r.id == record.id);
        });
      },
    );
  }

  /// Registros de hoy, más recientes primero
  List<HydrationRecord> get _todayRecords {
    final today = _records.where((r) => _isToday(r.timestamp)).toList();
    today.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return today;
  }

  Widget _buildProgressCard(BuildContext context) {
    final clampedProgress = _progress.clamp(0.0, 1.0);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💧', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'Meta diaria',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: clampedProgress,
                      strokeWidth: 12,
                      backgroundColor: Colors.blue.shade50,
                      valueColor: AlwaysStoppedAnimation(
                        _progress >= 1.0
                            ? AppTheme.secondaryColor
                            : Colors.blue.shade400,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_totalMl',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'de $_dailyGoalMl ml',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_glassesCount vasos (≈ 250ml c/u)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_progress >= 1.0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.secondaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '¡Meta alcanzada!',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Registro rápido', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickButton(
                context,
                icon: '💧',
                label: '1 vaso de agua',
                onTap: () async => await _addRecord(
                  HydrationRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    liquidType: LiquidType.water,
                    amountMl: 250,
                    timestamp: DateTime.now(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                context,
                icon: '🍵',
                label: '1 taza de té',
                onTap: () async => await _addRecord(
                  HydrationRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    liquidType: LiquidType.infusion,
                    amountMl: 200,
                    timestamp: DateTime.now(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                context,
                icon: '🧃',
                label: '1 jugo',
                onTap: () async => await _addRecord(
                  HydrationRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    liquidType: LiquidType.juice,
                    amountMl: 200,
                    timestamp: DateTime.now(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSummary(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _todaySummaryByType.entries.map((entry) {
        return Chip(
          avatar: Text(entry.key.icon, style: const TextStyle(fontSize: 16)),
          label: Text('${entry.key.label}: ${entry.value}ml'),
        );
      }).toList(),
    );
  }

  Widget _buildRecordTile(
    BuildContext context,
    HydrationRecord record,
    int index,
  ) {
    final timeStr = DateFormat('HH:mm').format(record.timestamp);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          record.liquidType.icon,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(record.liquidType.label),
        subtitle: Text('${record.amountMl}ml · $timeStr'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Colors.grey,
          onPressed: () => _deleteRecord(index),
        ),
      ),
    );
  }
}

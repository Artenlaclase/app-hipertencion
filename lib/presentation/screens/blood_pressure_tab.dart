import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/add_blood_pressure_dialog.dart';

class BloodPressureTab extends StatelessWidget {
  const BloodPressureTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presión Arterial')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Última medición
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Última Medición',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '-- / --',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'mmHg',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Sin datos',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Semáforo informativo
            Text('Referencia', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildReferenceItem('Normal', '< 120/80', AppTheme.pressureNormal),
            _buildReferenceItem(
              'Elevada',
              '120-129 / < 80',
              AppTheme.pressureElevated,
            ),
            _buildReferenceItem(
              'Alta',
              '130-179 / 80-119',
              AppTheme.pressureHigh,
            ),
            _buildReferenceItem('Crisis', '≥ 180/120', AppTheme.pressureCrisis),

            const SizedBox(height: 20),
            Text('Historial', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.timeline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Registra tu primera medición\npara ver tu historial aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const AddBloodPressureDialog(),
          );
          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registrado: ${result['systolic']?.toInt()}/${result['diastolic']?.toInt()} mmHg',
                ),
                backgroundColor: AppTheme.secondaryColor,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
    );
  }
}

Widget _buildReferenceItem(String label, String range, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(range, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

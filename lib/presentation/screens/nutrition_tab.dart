import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/add_food_record_dialog.dart';

class NutritionTab extends StatelessWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Código muerto eliminado
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrición')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del día
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de Hoy',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildNutrientBar(
                      context,
                      label: 'Sodio',
                      current: 0,
                      max: 1500,
                      unit: 'mg',
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientBar(
                      context,
                      label: 'Potasio',
                      current: 0,
                      max: 4700,
                      unit: 'mg',
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientBar(
                      context,
                      label: 'Calorías',
                      current: 0,
                      max: 2000,
                      unit: 'kcal',
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Plan del día
            Text(
              'Plan Alimenticio DASH',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildMealCard(context, '🌅', 'Desayuno', 'Sin plan generado'),
            _buildMealCard(context, '☀️', 'Almuerzo', 'Sin plan generado'),
            _buildMealCard(context, '🌙', 'Cena', 'Sin plan generado'),
            _buildMealCard(context, '🍎', 'Snacks', 'Sin plan generado'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const AddFoodRecordDialog(),
          );
          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${result['name']} registrado en ${result['mealType']}',
                ),
                backgroundColor: AppTheme.secondaryColor,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Alimento'),
      ),
    );
  }

  Widget _buildNutrientBar(
    BuildContext context, {
    required String label,
    required double current,
    required double max,
    required String unit,
    required Color color,
  }) {
    final progress = (current / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${current.toInt()} / ${max.toInt()} $unit',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

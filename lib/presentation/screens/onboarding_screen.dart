import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(UserProfile) onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Una FormKey por página para validar independientemente
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  // Datos del formulario
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();

  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  HypertensionLevel _hypertensionLevel = HypertensionLevel.mild;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validar la página actual antes de avanzar
    if (!(_formKeys[_currentPage].currentState?.validate() ?? false)) return;

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _submitForm() {
    // Validar la última página
    if (!(_formKeys[_currentPage].currentState?.validate() ?? false)) return;

    // Parseo seguro con tryParse
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final systolic = double.tryParse(_systolicController.text);
    final diastolic = double.tryParse(_diastolicController.text);

    if (age == null ||
        weight == null ||
        height == null ||
        systolic == null ||
        diastolic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa que todos los valores numéricos sean válidos'),
        ),
      );
      return;
    }

    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      age: age,
      gender: _gender,
      weight: weight,
      height: height,
      activityLevel: _activityLevel,
      hypertensionLevel: _hypertensionLevel,
      initialSystolic: systolic,
      initialDiastolic: diastolic,
      createdAt: DateTime.now(),
      hasAcceptedDisclaimer: true,
    );
    widget.onCompleted(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Inicial'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Indicador de progreso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Páginas
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPersonalDataPage(),
                _buildBodyDataPage(),
                _buildActivityPage(),
                _buildBloodPressurePage(),
              ],
            ),
          ),
          // Botón
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                child: Text(_currentPage < 3 ? 'Siguiente' : 'Comenzar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataPage() {
    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Personales',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Necesitamos algunos datos para personalizar tu experiencia.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Ingrese su nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Edad',
                prefixIcon: Icon(Icons.cake_outlined),
                suffixText: 'años',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Ingrese su edad' : null,
            ),
            const SizedBox(height: 16),
            Text('Sexo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SegmentedButton<Gender>(
              segments: const [
                ButtonSegment(value: Gender.male, label: Text('Masculino')),
                ButtonSegment(value: Gender.female, label: Text('Femenino')),
              ],
              selected: {_gender},
              onSelectionChanged: (v) => setState(() => _gender = v.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyDataPage() {
    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Corporales',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta información nos ayudará a personalizar tu plan nutricional.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Ingrese su peso' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Altura',
                prefixIcon: Icon(Icons.height),
                suffixText: 'cm',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Ingrese su altura' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPage() {
    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel de Actividad',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona tu nivel de actividad física habitual.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ..._buildActivityOptions(),
            const SizedBox(height: 24),
            Text(
              'Tipo de Hipertensión',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ..._buildHypertensionOptions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActivityOptions() {
    final options = {
      ActivityLevel.sedentary: ('Sedentario', 'Poco o nada de ejercicio'),
      ActivityLevel.light: ('Ligero', 'Ejercicio 1-3 días/semana'),
      ActivityLevel.moderate: ('Moderado', 'Ejercicio 3-5 días/semana'),
      ActivityLevel.active: ('Activo', 'Ejercicio 6-7 días/semana'),
      ActivityLevel.veryActive: ('Muy activo', 'Ejercicio intenso diario'),
    };
    return [
      RadioGroup<ActivityLevel>(
        groupValue: _activityLevel,
        onChanged: (v) => setState(() => _activityLevel = v ?? _activityLevel),
        child: Column(
          children: options.entries.map((e) {
            return RadioListTile<ActivityLevel>(
              title: Text(e.value.$1),
              subtitle: Text(e.value.$2),
              value: e.key,
            );
          }).toList(),
        ),
      ),
    ];
  }

  List<Widget> _buildHypertensionOptions() {
    final options = {
      HypertensionLevel.mild: ('Leve', 'PA 140-159 / 90-99 mmHg'),
      HypertensionLevel.moderate: ('Moderada', 'PA 160-179 / 100-109 mmHg'),
      HypertensionLevel.severe: ('Severa', 'PA ≥180 / ≥110 mmHg'),
    };
    return [
      RadioGroup<HypertensionLevel>(
        groupValue: _hypertensionLevel,
        onChanged: (v) =>
            setState(() => _hypertensionLevel = v ?? _hypertensionLevel),
        child: Column(
          children: options.entries.map((e) {
            return RadioListTile<HypertensionLevel>(
              title: Text(e.value.$1),
              subtitle: Text(e.value.$2),
              value: e.key,
            );
          }).toList(),
        ),
      ),
    ];
  }

  Widget _buildBloodPressurePage() {
    return Form(
      key: _formKeys[3],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Presión Arterial Inicial',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu última medición de presión arterial.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _systolicController,
              decoration: const InputDecoration(
                labelText: 'Sistólica (alta)',
                prefixIcon: Icon(Icons.favorite_outline),
                suffixText: 'mmHg',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Ingrese presión sistólica' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diastolicController,
              decoration: const InputDecoration(
                labelText: 'Diastólica (baja)',
                prefixIcon: Icon(Icons.favorite_border),
                suffixText: 'mmHg',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Ingrese presión diastólica' : null,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Usa los valores de tu última consulta médica o medición confiable.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

# Informe de Desarrollo — HTApp

**Fecha:** 7 de febrero de 2026  
**Proyecto:** HTApp — Aplicación Móvil para Pacientes con Hipertensión Arterial  
**Framework:** Flutter 3.38.9 · Dart 3.10.8  
**Plataforma de desarrollo:** Windows 11 · Android SDK 36.1.0

---

## Índice

1. [Fase 1 — Arquitectura Base](#fase-1--arquitectura-base)
2. [Fase 2 — Resolución de Errores Iniciales](#fase-2--resolución-de-errores-iniciales)
3. [Fase 3 — Configuración del Entorno Android](#fase-3--configuración-del-entorno-android)
4. [Fase 4 — Implementación del Dominio (SRS)](#fase-4--implementación-del-dominio-srs)
5. [Fase 5 — Capa de Presentación](#fase-5--capa-de-presentación)
6. [Fase 6 — Resolución de Errores de Presentación](#fase-6--resolución-de-errores-de-presentación)
7. [Fase 7 — Resolución de Error en Runtime](#fase-7--resolución-de-error-en-runtime)
8. [Fase 8 — Implementación de TODOs (Formularios e Interacción)](#fase-8--implementación-de-todos-formularios-e-interacción)
9. [Fase 9 — Resolución de FormatException en Onboarding](#fase-9--resolución-de-formatexception-en-onboarding)
10. [Resumen de Errores Resueltos](#resumen-de-errores-resueltos)
11. [Estado Actual del Proyecto](#estado-actual-del-proyecto)
12. [Estructura de Archivos](#estructura-de-archivos)
13. [Próximos Pasos](#próximos-pasos)

---

## Fase 1 — Arquitectura Base

### Objetivo
Establecer la estructura de carpetas y archivos base siguiendo **Clean Architecture**.

### Acciones Realizadas

| # | Acción | Archivos |
|---|--------|----------|
| 1 | Creación de estructura de directorios (4 capas) | `lib/core/`, `lib/data/`, `lib/domain/`, `lib/presentation/` |
| 2 | Caso de uso abstracto | `lib/core/usecases/usecase.dart` |
| 3 | Errores y excepciones | `lib/core/errors/failures.dart`, `exceptions.dart` |
| 4 | Verificación de red | `lib/core/network/network_info.dart` |
| 5 | Router centralizado | `lib/core/routes/app_router.dart` |
| 6 | Inyección de dependencias | `lib/injection_container.dart` |
| 7 | Instalación de dependencias | `dartz`, `equatable`, `get_it`, `connectivity_plus` |

### Dependencias Añadidas (`pubspec.yaml`)

```yaml
dependencies:
  dartz: ^0.10.1         # Programación funcional (Either)
  equatable: ^2.0.8      # Igualdad por valor
  get_it: ^9.2.0         # Inyección de dependencias
  connectivity_plus: ^7.0.0  # Verificación de conectividad
```

---

## Fase 2 — Resolución de Errores Iniciales

### Error 1: `network_info.dart` — Comparación de `ConnectivityResult`

**Descripción:** `checkConnectivity()` de `connectivity_plus` v7 retorna `List<ConnectivityResult>` en lugar de un solo valor.

**Código con error:**
```dart
return result != ConnectivityResult.none;
```

**Corrección:**
```dart
return !result.contains(ConnectivityResult.none);
```

**Causa raíz:** Breaking change en `connectivity_plus` v6+. La firma cambió de `Future<ConnectivityResult>` a `Future<List<ConnectivityResult>>`.

---

### Error 2: `usecase.dart` — Conflicto con tipo `Type` de Dart

**Descripción:** El genérico se nombró `Type`, que colisiona con el `Type` built-in de Dart.

**Código con error:**
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
```

**Corrección:**
```dart
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
```

**Causa raíz:** `Type` es una clase reservada en `dart:core`. Renombrar a `T` sigue la convención estándar de genéricos.

---

## Fase 3 — Configuración del Entorno Android

### 3.1 Instalación del Android NDK

El build de Android requería el NDK para compilar código nativo de Flutter.

```powershell
sdkmanager "ndk;28.2.13676358"
```

**Resultado:** NDK instalado exitosamente en `C:\Users\...\AppData\Local\Android\Sdk\ndk\28.2.13676358`.

### 3.2 Resolución de Emulador

**Problema:** El emulador Pixel 3 XL no arrancaba o generaba timeout al intentar `flutter run`.

**Solución:**
1. Iniciar emulador como proceso independiente:
   ```powershell
   Start-Process emulator -ArgumentList "-avd Pixel_3_XL" -WindowStyle Hidden
   ```
2. Verificar conexión:
   ```powershell
   adb devices
   # → emulator-5554   device
   ```
3. Ejecutar la app:
   ```powershell
   flutter run
   ```

---

## Fase 4 — Implementación del Dominio (SRS)

### Objetivo
Implementar las entidades, repositorios e interfaces y casos de uso a partir del documento de Especificación de Requisitos de Software (SRS) para manejo de hipertensión.

### 4.1 Entidades del Dominio

| Entidad | Archivo | Descripción |
|---------|---------|-------------|
| `UserProfile` | `domain/entities/user_profile.dart` | Perfil del paciente con enums `Gender`, `ActivityLevel`, `HypertensionLevel` |
| `BloodPressure` | `domain/entities/blood_pressure.dart` | Medición PA con getter `category` computado y enum `PressureCategory` |
| `Food` | `domain/entities/food.dart` | Alimento con información nutricional y enum `SodiumLevel` |
| `FoodRecord` | `domain/entities/food_record.dart` | Registro de consumo de alimento vinculado a un `Food` |
| `MealPlan` | `domain/entities/meal_plan.dart` | Plan alimenticio DASH (desayuno/almuerzo/cena/snacks) |
| `EducationContent` | `domain/entities/education_content.dart` | Contenido educativo categorizado con orden |
| `Habit` | `domain/entities/habit.dart` | Hábito con fechas completadas y getter `currentStreak` |
| `Reminder` | `domain/entities/reminder.dart` | Recordatorio con hora, minuto, días de la semana |

### 4.2 Interfaces de Repositorio

| Repositorio | Archivo | Métodos principales |
|-------------|---------|---------------------|
| `UserRepository` | `domain/repositories/user_repository.dart` | `createProfile`, `getProfile`, `updateProfile`, `acceptDisclaimer`, `hasCompletedOnboarding` |
| `BloodPressureRepository` | `domain/repositories/blood_pressure_repository.dart` | `addRecord`, `getRecords`, `getRecordsByDateRange`, `getLatestRecord`, `deleteRecord` |
| `NutritionRepository` | `domain/repositories/nutrition_repository.dart` | `getFoods`, `searchFoods`, `addFoodRecord`, `getMealPlan`, `generateMealPlan` |
| `EducationRepository` | `domain/repositories/education_repository.dart` | `getContents`, `getContentsByCategory`, `markAsRead` |
| `HabitRepository` | `domain/repositories/habit_repository.dart` | CRUD hábitos/recordatorios, `completeHabit`, `toggleReminder` |

### 4.3 Casos de Uso (MVP)

| Caso de Uso | Archivo | RF |
|-------------|---------|-----|
| `CreateUserProfile` | `domain/usecases/create_user_profile.dart` | RF-01 |
| `GetUserProfile` | `domain/usecases/get_user_profile.dart` | RF-01 |
| `AddBloodPressure` | `domain/usecases/add_blood_pressure.dart` | RF-02 |
| `GetBloodPressureHistory` | `domain/usecases/get_blood_pressure_history.dart` | RF-02 |
| `GetMealPlan` | `domain/usecases/get_meal_plan.dart` | RF-03/RF-04 |
| `AddFoodRecord` | `domain/usecases/add_food_record.dart` | RF-05 |
| `GetEducationContents` | `domain/usecases/get_education_contents.dart` | RF-06/RF-07 |
| `AcceptDisclaimer` | `domain/usecases/accept_disclaimer.dart` | RF-11 |

---

## Fase 5 — Capa de Presentación

### 5.1 Tema y Constantes

| Archivo | Contenido |
|---------|-----------|
| `core/theme/app_theme.dart` | Tema Material 3, colores semáforo PA (normal/elevada/alta/crisis), tipografía, decoración de inputs |
| `core/constants/app_constants.dart` | Rangos sistólica/diastólica, límites DASH (Na ≤ 1500 mg, K ≥ 4700 mg), texto del disclaimer médico |

### 5.2 Pantallas

| Pantalla | Archivo | Función |
|----------|---------|---------|
| `DisclaimerScreen` | `presentation/screens/disclaimer_screen.dart` | Aviso legal médico obligatorio con botón "Acepto" |
| `OnboardingScreen` | `presentation/screens/onboarding_screen.dart` | Formulario de 4 pasos: datos personales, corporales, actividad + nivel HTA, PA inicial |
| `HomeScreen` | `presentation/screens/home_screen.dart` | Contenedor con `BottomNavigationBar` de 5 tabs |
| `HomeTab` | `presentation/screens/home_tab.dart` | Resumen: tarjeta PA, nutrición, hábitos + tip del día |
| `BloodPressureTab` | `presentation/screens/blood_pressure_tab.dart` | Última medición, semáforo referencia, historial |
| `NutritionTab` | `presentation/screens/nutrition_tab.dart` | Barras de nutrientes (Na/K/kcal), plan DASH |
| `EducationTab` | `presentation/screens/education_tab.dart` | 4 categorías educativas con conteo de artículos |
| `HabitsTab` | `presentation/screens/habits_tab.dart` | Progreso circular, hábitos sugeridos |

### 5.3 Flujo de Navegación

```
Disclaimer (/) → Onboarding (/onboarding) → Home (/home)
                                                ├── Inicio
                                                ├── Presión Arterial
                                                ├── Nutrición
                                                ├── Educación
                                                └── Hábitos
```

---

## Fase 6 — Resolución de Errores de Presentación

### Error 3: `CardTheme` → `CardThemeData`

**Descripción:** En Flutter 3.38+, el constructor `CardTheme()` dentro de `ThemeData` espera `CardThemeData`.

**Código con error:**
```dart
cardTheme: CardTheme(
  elevation: 0,
  ...
),
```

**Corrección:**
```dart
cardTheme: CardThemeData(
  elevation: 0,
  ...
),
```

---

### Error 4: `RadioListTile` deprecated API (Flutter 3.32+)

**Descripción:** Los parámetros `groupValue` y `onChanged` de `RadioListTile` fueron deprecados. Flutter introdujo `RadioGroup<T>` como wrapper.

**Código con error:**
```dart
RadioListTile<Gender>(
  value: Gender.male,
  groupValue: _selectedGender,
  onChanged: (v) => setState(() => _selectedGender = v ?? Gender.male),
  title: Text('Masculino'),
),
```

**Corrección:**
```dart
RadioGroup<Gender>(
  groupValue: _selectedGender,
  onChanged: (v) => setState(() => _selectedGender = v ?? Gender.male),
  child: Column(
    children: [
      RadioListTile<Gender>(
        value: Gender.male,
        title: Text('Masculino'),
      ),
      // ...más opciones
    ],
  ),
),
```

**Nota:** El callback `onChanged` de `RadioGroup<T>` recibe `T?` (nullable), por lo que se usa `?? valorDefault` como fallback.

---

## Fase 7 — Resolución de Error en Runtime

### Error 5: Null Check Operator — Error de Ruta Inicial

**Descripción:** Al ejecutar la app, se producía un error `Null check operator used on a null value` al arrancar. Flutter con `initialRoute: '/disclaimer'` divide la ruta por `/` e intenta generar la ruta para `/` antes de `/disclaimer`.

**Manifiesto del error:**
```
Null check operator used on a null value
```

**Causa raíz:** `MaterialApp(initialRoute: '/disclaimer')` genera internamente dos rutas: `/` y `/disclaimer`. La ruta `/` no estaba definida en `generateRoute`.

**Corrección:**
1. Cambiar la ruta del disclaimer de `'/disclaimer'` a `'/'`:
   ```dart
   class AppRoutes {
     static const String disclaimer = '/';
   }
   ```
2. Eliminar `initialRoute` de `MaterialApp` (usa `/` por defecto):
   ```dart
   MaterialApp(
     // sin initialRoute — usa '/' que es DisclaimerScreen
     onGenerateRoute: AppRouter.generateRoute,
   )
   ```

**Resultado:** App arranca correctamente mostrando el Disclaimer como primera pantalla.

---

## Fase 8 — Implementación de TODOs (Formularios e Interacción)

### Objetivo
Reemplazar los 5 comentarios `TODO` que `flutter analyze` reportaba como warnings en las pantallas de tabs.

### 8.1 Formulario de Registro de Presión Arterial

**Archivo creado:** `presentation/widgets/add_blood_pressure_dialog.dart`

**Características:**
- Pantalla completa (`Dialog.fullscreen`)
- Campos: Sistólica (60-300), Diastólica (30-200), Pulso (opcional), Notas (opcional)
- **Indicador de categoría en tiempo real**: al escribir los valores, muestra badge de color según el semáforo (Normal/Elevada/Alta/Crisis)
- Validación de formulario con rango de valores
- Retorna `Map<String, dynamic>` con los datos del registro

**TODO resuelto:** `// TODO: Abrir formulario de registro` en `blood_pressure_tab.dart`

---

### 8.2 Formulario de Registro de Alimento

**Archivo creado:** `presentation/widgets/add_food_record_dialog.dart`

**Características:**
- Pantalla completa (`Dialog.fullscreen`)
- Selector de tipo de comida con `SegmentedButton` (Desayuno/Almuerzo/Cena/Snack)
- Buscador de alimentos con filtro en tiempo real
- Lista de 15 alimentos demo con emoji, categoría, badge de nivel de sodio (Bajo/Medio/Alto)
- Indicador de recomendado (👍) o precaución (⚠️) según dieta DASH
- Retorna datos del alimento seleccionado

**TODO resuelto:** `// TODO: Registrar alimento` en `nutrition_tab.dart`

---

### 8.3 Pantalla de Artículos Educativos

**Archivo creado:** `presentation/screens/education_articles_screen.dart`

**Características:**
- Navegación desde cada categoría del tab Educación
- Artículos completos con título, resumen, cuerpo y tiempo de lectura
- Vista de detalle con scroll y tipografía legible
- **Contenido por categoría:**
  - Impacto del Sodio: 3 artículos
  - Lectura de Etiquetas: 2 artículos
  - Mitos Alimentarios: 4 artículos
  - Dieta DASH: 3 artículos
- Total: **12 artículos educativos** con contenido validado

**TODO resuelto:** `// TODO: Navegar a lista de artículos` en `education_tab.dart`

---

### 8.4 Diálogo de Creación de Hábito

**Archivo creado:** `presentation/widgets/add_habit_dialog.dart`

**Características:**
- `AlertDialog` con selección visual de ícono (10 emojis disponibles)
- Campos: nombre (requerido), descripción (opcional)
- Soporte para pre-rellenado (usado al agregar hábitos sugeridos)
- Validación de campo obligatorio
- Retorna datos del nuevo hábito

**TODOs resueltos:**
- `// TODO: Crear hábito personalizado` en FAB de `habits_tab.dart`
- `// TODO: Agregar hábito` en botón "+" de cada hábito sugerido (abre diálogo pre-rellenado)

---

## Fase 9 — Resolución de FormatException en Onboarding

### Error 6: `FormatException: Invalid number` al completar el onboarding

**Descripción:** Al llegar a la última página del onboarding (Presión Arterial Inicial) y pulsar "Comenzar", se producía una excepción `FormatException: Invalid number (at character 1)` en `_submitForm()` línea 59.

**Manifiesto del error:**
```
══╡ EXCEPTION CAUGHT BY GESTURE ╞═══════════════════════════════════
The following FormatException was thrown while handling a gesture:
Invalid number (at character 1)
^

#0  int._handleFormatError (dart:core-patch/integers_patch.dart:150:5)
#1  int.parse (dart:core-patch/integers_patch.dart:71:14)
#2  _OnboardingScreenState._submitForm
    (package:htapp/presentation/screens/onboarding_screen.dart:59:18)
```

**Causa raíz:** El `Form` global envolvía todo el `PageView`, pero `PageView` **descarta (dispose) las páginas fuera de pantalla** para optimizar memoria. Cuando el usuario llegaba a la página 4 y pulsaba "Comenzar":

1. `_formKey.currentState?.validate()` solo validaba los campos **visibles** (página 4: sistólica/diastólica)
2. Los `TextEditingController` de páginas anteriores (edad, peso, altura) conservaban su texto
3. **Pero** si el usuario no había ingresado datos en esas páginas, los controllers estaban vacíos (`""`)
4. `int.parse("")` lanzaba `FormatException`

El problema fundamental: **un solo `Form` no puede validar campos de múltiples páginas de un `PageView`**, porque los widgets de páginas no visibles no existen en el árbol.

**Corrección aplicada (3 cambios):**

1. **Form individual por página** — Cada página del `PageView` tiene su propio `Form` con su `GlobalKey<FormState>` independiente:
   ```dart
   final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

   Widget _buildPersonalDataPage() {
     return Form(
       key: _formKeys[0],  // FormKey exclusiva para esta página
       child: SingleChildScrollView(...),
     );
   }
   ```

2. **Validación antes de avanzar** — `_nextPage()` valida la página actual e impide avanzar si hay campos vacíos:
   ```dart
   void _nextPage() {
     if (!(_formKeys[_currentPage].currentState?.validate() ?? false)) return;
     // ... avanzar o submit
   }
   ```

3. **Parseo seguro con `tryParse`** — `_submitForm()` usa `tryParse` como guard adicional en lugar de `parse` directo:
   ```dart
   final age = int.tryParse(_ageController.text);
   final weight = double.tryParse(_weightController.text);
   // ...
   if (age == null || weight == null || ...) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Revisa que todos los valores numéricos sean válidos')),
     );
     return;
   }
   ```

**Resultado:** El onboarding valida cada paso antes de permitir avanzar. Si un campo está vacío o tiene valor inválido, el usuario no puede pasar a la siguiente página. El `FormatException` ya no se produce.

---

## Resumen de Errores Resueltos

| # | Error | Archivo | Tipo | Causa | Solución |
|---|-------|---------|------|-------|----------|
| 1 | Comparación `ConnectivityResult` | `network_info.dart` | Lint | `connectivity_plus` v7 retorna `List` | Usar `.contains()` en lugar de `!=` |
| 2 | Conflicto genérico `Type` | `usecase.dart` | Lint | `Type` es clase de `dart:core` | Renombrar a `T` |
| 3 | `CardTheme` constructor | `app_theme.dart` | Compilación | Flutter 3.38+ cambió API | Usar `CardThemeData` |
| 4 | `RadioListTile` deprecated | `onboarding_screen.dart` | Deprecation | Flutter 3.32+ deprecó `groupValue`/`onChanged` | Usar wrapper `RadioGroup<T>` |
| 5 | Null check en ruta inicial | `app_router.dart` / `main.dart` | Runtime | Flutter divide `initialRoute` por `/` | Hacer disclaimer la ruta raíz `/` |
| 6 | `FormatException` en onboarding | `onboarding_screen.dart` | Runtime | `PageView` descarta páginas; `Form` global no valida campos inexistentes; `int.parse("")` falla | Form individual por página + validación por paso + `tryParse` |

---

## Estado Actual del Proyecto

### Resultado de `flutter analyze`

```
Analyzing htapp...
No issues found! (ran in 2.2s)
```

### Verificación en Emulador

- **Dispositivo:** Pixel 3 XL (emulator-5554)
- **Estado:** App ejecuta correctamente
- **Flujo verificado:** Disclaimer → Onboarding → Home (5 tabs funcionales)

### Capas Implementadas

| Capa | Estado | Detalle |
|------|--------|---------|
| Core | ✅ Completo | Errors, network, routes, usecases, theme, constants |
| Domain | ✅ Completo | 8 entidades, 5 repositorios, 8 casos de uso |
| Presentation | ✅ Completo (UI) | 8 pantallas + 3 dialogs/widgets + 1 pantalla artículos |
| Data | ⏳ Pendiente | Modelos, datasources, implementaciones de repositorio |
| State Management | ⏳ Pendiente | BLoC/Cubit por feature |
| DI Wiring | ⏳ Pendiente | Registro en `injection_container.dart` |

---

## Estructura de Archivos

```
lib/
├── main.dart
├── injection_container.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── routes/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── usecases/
│       └── usecase.dart
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   │   ├── blood_pressure.dart
│   │   ├── education_content.dart
│   │   ├── food.dart
│   │   ├── food_record.dart
│   │   ├── habit.dart
│   │   ├── meal_plan.dart
│   │   ├── reminder.dart
│   │   └── user_profile.dart
│   ├── repositories/
│   │   ├── blood_pressure_repository.dart
│   │   ├── education_repository.dart
│   │   ├── habit_repository.dart
│   │   ├── nutrition_repository.dart
│   │   └── user_repository.dart
│   └── usecases/
│       ├── accept_disclaimer.dart
│       ├── add_blood_pressure.dart
│       ├── add_food_record.dart
│       ├── create_user_profile.dart
│       ├── get_blood_pressure_history.dart
│       ├── get_education_contents.dart
│       ├── get_meal_plan.dart
│       └── get_user_profile.dart
└── presentation/
    ├── screens/
    │   ├── blood_pressure_tab.dart
    │   ├── disclaimer_screen.dart
    │   ├── education_articles_screen.dart
    │   ├── education_tab.dart
    │   ├── habits_tab.dart
    │   ├── home_screen.dart
    │   ├── home_tab.dart
    │   ├── nutrition_tab.dart
    │   └── onboarding_screen.dart
    └── widgets/
        ├── add_blood_pressure_dialog.dart
        ├── add_food_record_dialog.dart
        └── add_habit_dialog.dart
```

---

## Próximos Pasos

| Prioridad | Tarea | Descripción |
|-----------|-------|-------------|
| 🔴 Alta | Capa Data | Implementar modelos (fromJson/toJson), datasources locales (SQLite/Hive), repositorios concretos |
| 🔴 Alta | State Management | Agregar BLoC/Cubit por feature (PA, nutrición, educación, hábitos) |
| 🔴 Alta | DI Wiring | Registrar todas las dependencias en `injection_container.dart` |
| 🟡 Media | Persistencia | Conectar formularios a almacenamiento local |
| 🟡 Media | Gráficas PA | Historial visual con gráficas de presión arterial (fl_chart) |
| 🟡 Media | Notificaciones | Implementar recordatorios con `flutter_local_notifications` |
| 🟢 Baja | Tests unitarios | Tests para use cases, repositorios, BLoCs |
| 🟢 Baja | Tests de widgets | Tests para pantallas y formularios |

---

*Informe actualizado el 7 de febrero de 2026.*

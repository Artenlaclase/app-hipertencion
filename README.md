# HTApp

Aplicación móvil desarrollada con **Flutter**, estructurada bajo los principios de **Clean Architecture**.

---

## Arquitectura del Proyecto

El proyecto sigue el patrón de **Arquitectura Limpia (Clean Architecture)**, que separa las responsabilidades en capas independientes para lograr un código mantenible, testeable y escalable.

### Diagrama de Capas

```
┌──────────────────────────────────────────────┐
│              Presentation Layer               │
│  (screens, widgets, bloc/state management)    │
├──────────────────────────────────────────────┤
│                Domain Layer                   │
│    (entities, usecases, repositories)         │
├──────────────────────────────────────────────┤
│                 Data Layer                    │
│  (models, datasources, repository impl)       │
├──────────────────────────────────────────────┤
│                 Core Layer                    │
│  (errors, network, routes, usecases base)     │
└──────────────────────────────────────────────┘
```

### Estructura de Carpetas

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── injection_container.dart     # Inyección de dependencias (GetIt)
│
├── core/                        # Utilidades y componentes compartidos
│   ├── errors/
│   │   ├── exceptions.dart      # Excepciones personalizadas
│   │   └── failures.dart        # Clases de fallo (Failure)
│   ├── network/
│   │   └── network_info.dart    # Verificación de conectividad
│   ├── routes/
│   │   └── app_router.dart      # Gestión de rutas/navegación
│   ├── services/                # Servicios compartidos
│   └── usecases/
│       └── usecase.dart         # Clase base abstracta para casos de uso
│
├── data/                        # Capa de datos
│   ├── datasources/             # Fuentes de datos (API, local DB, etc.)
│   ├── models/                  # Modelos de datos (JSON ↔ Dart)
│   └── repositories/            # Implementación de repositorios
│
├── domain/                      # Capa de dominio (lógica de negocio)
│   ├── entities/                # Entidades del negocio
│   ├── repositories/            # Contratos/interfaces de repositorios
│   └── usecases/                # Casos de uso
│
└── presentation/                # Capa de presentación (UI)
    ├── bloc/                    # Gestión de estado (BLoC/Cubit)
    ├── screens/                 # Pantallas de la aplicación
    └── widgets/                 # Widgets reutilizables
```

---

## Descripción de las Capas

### Core
Contiene utilidades transversales utilizadas por todas las capas:
- **errors/**: Define `Failure` y `Exception` personalizados para un manejo de errores consistente.
- **network/**: Verifica la conectividad a internet mediante `connectivity_plus`.
- **routes/**: Centraliza la navegación de la aplicación con `AppRouter`.
- **usecases/**: Define la clase abstracta `UseCase<Type, Params>` que todos los casos de uso deben implementar.

### Domain
Es el núcleo de la aplicación. No depende de ningún framework externo:
- **entities/**: Objetos de negocio puros (sin dependencias de Flutter o paquetes externos).
- **repositories/**: Interfaces abstractas que definen los contratos de acceso a datos.
- **usecases/**: Cada caso de uso representa una acción específica del negocio y retorna `Either<Failure, Type>`.

### Data
Implementa los contratos definidos en la capa de dominio:
- **models/**: Extienden las entidades e incluyen métodos de serialización (`fromJson`, `toJson`).
- **datasources/**: Fuentes concretas de datos (API remota, caché local, etc.).
- **repositories/**: Implementaciones de los repositorios que coordinan las fuentes de datos.

### Presentation
Todo lo relacionado con la interfaz de usuario:
- **bloc/**: Gestión de estado usando el patrón BLoC o Cubit.
- **screens/**: Pantallas completas de la aplicación.
- **widgets/**: Componentes de UI reutilizables.

---

## Dependencias Principales

| Paquete | Propósito |
|---|---|
| `dartz` | Programación funcional (`Either`, `Option`) para manejo de errores |
| `equatable` | Comparación de igualdad simplificada entre objetos |
| `get_it` | Inyección de dependencias (Service Locator) |
| `connectivity_plus` | Verificación de estado de conectividad de red |

---

## Flujo de Datos

```
UI (Screen) → BLoC/Cubit → UseCase → Repository (abstract) → Repository (impl) → DataSource
```

1. La **pantalla** dispara un evento al **BLoC**.
2. El **BLoC** ejecuta un **caso de uso**.
3. El **caso de uso** llama al **repositorio** (interfaz del dominio).
4. La **implementación del repositorio** decide si obtener datos del **datasource remoto** o del **datasource local**.
5. Los datos fluyen de vuelta en forma de `Either<Failure, Entity>`.

---

## Cómo Empezar

### Requisitos Previos
- Flutter SDK instalado
- Dart SDK incluido con Flutter

### Instalación

```bash
# Clonar el repositorio
git clone <url-del-repositorio>

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

---

## Plataformas Soportadas

- Android
- iOS
- Web
- Windows
- macOS
- Linux


# Resumen de Cambios y Correcciones en la App Móvil (Febrero 2026)

## 1. Cambio de Contraseña
- Se implementó la lógica para guardar la nueva contraseña en el servidor desde la pantalla de cambio de contraseña (`change_password_screen.dart`).
- Se utilizó la inyección de dependencias (`GetIt`) para acceder a `AuthRemoteDataSource`.
- Se corrigieron errores de contexto y declaración de funciones:
  - Se movió la función de cambio de contraseña fuera del callback del botón.
  - Se protegió el uso de `BuildContext` tras operaciones asíncronas usando `if (!mounted) return;`.
  - Se eliminó el argumento duplicado `child` en el `ElevatedButton`.
  - Se agregó un indicador de carga (`CircularProgressIndicator`) mientras se realiza la operación.

## 2. Edición de Perfil
- Se corrigió el uso de `BuildContext` tras un gap asíncrono en la pantalla de edición de perfil (`edit_profile_screen.dart`).
- Ahora se verifica `mounted` antes de mostrar el `SnackBar` tras guardar los datos editados en almacenamiento local.

## 3. Personalización Visual: Logo, Colores y Fuente
- **Logo:**
  - Se agregó el logo de la aplicación (`assets/logo_app.png`).
  - El logo se muestra en la pantalla principal (`home_tab.dart`) usando `Image.asset('assets/logo_app.png')`.
- **Colores y Tema:**
  - Se definió una paleta de colores personalizada en `core/theme/app_theme.dart`.
  - El color principal es azul sereno (`#2C7699`), junto con colores secundarios y de estado (verde, coral, amarillo, etc.).
  - Se personalizaron los temas de AppBar, botones, tarjetas, campos de texto y navegación inferior.
- **Fuente:**
  - Se integró la fuente `Nunito` (archivos en `fonts/Nunito-Regular.ttf` y `fonts/Nunito-Bold.ttf`).
  - Se configuró en el tema global (`app_theme.dart`) y en `pubspec.yaml`.
  - Todos los estilos de texto usan la familia `Nunito` para mantener coherencia visual.

## 4. Limpieza de Errores
- Se eliminaron advertencias y errores relacionados con:
  - Uso de variables y funciones antes de su declaración.
  - Importaciones y dependencias no declaradas.
  - Argumentos duplicados en widgets.
  - Uso incorrecto de `BuildContext` tras operaciones asíncronas.

## 5. Buenas Prácticas
- Se siguieron las recomendaciones de Flutter para el manejo seguro de contexto y estado en widgets con operaciones asíncronas.
- Se mejoró la experiencia de usuario mostrando mensajes claros y estados de carga.

---

**Fecha:** 11 de febrero de 2026

**Archivos principales modificados:**
- `lib/presentation/screens/change_password_screen.dart`
- `lib/presentation/screens/edit_profile_screen.dart`
- `lib/core/theme/app_theme.dart`
- `lib/presentation/screens/home_tab.dart`
- `pubspec.yaml`

**Recursos agregados:**
- `assets/logo_app.png`
- `fonts/Nunito-Regular.ttf`
- `fonts/Nunito-Bold.ttf`

Si necesitas detalles de algún cambio específico, por favor indícalo.
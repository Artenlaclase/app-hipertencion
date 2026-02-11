# Actualización App Hipertensión — Febrero 2026

## Cambios implementados en la app móvil

### 1. Recuperación y restablecimiento de contraseña
- Nueva pantalla: `ForgotPasswordScreen` para solicitar email de recuperación.
- Nueva pantalla: `ResetPasswordScreen` para ingresar token y nueva contraseña.
- Métodos agregados en `AuthRemoteDataSource`:
  - `forgotPassword(email)` — Envía email de recuperación.
  - `resetPassword(token, newPassword)` — Restablece contraseña.
  - `validateResetToken(token)` — Valida el token de recuperación.

### 2. Integración con endpoints Laravel
- Se usan los endpoints:
  - `POST /forgot-password`
  - `POST /reset-password`
  - `POST /validate-reset-token`

### 3. Errores corregidos
- Error: "undefined name 'GetIt'" — Solucionado importando `package:get_it/get_it.dart`.
- Error: "The name 'AuthRemoteDataSource' isn't a type" — Solucionado importando `../../data/datasources/auth_remote_datasource.dart`.
- Validación de token antes de restablecer contraseña.

### 4. Mejoras
- Mensajes claros para usuario en caso de error o éxito.
- Validación de email y contraseña en formularios.

---

**Fecha:** 2026-02-11
**Responsable:** Raúl Rosales

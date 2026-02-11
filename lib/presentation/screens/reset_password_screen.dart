import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final sl = GetIt.instance;
      final authDataSource = sl<AuthRemoteDataSource>();
      final token = _tokenController.text.trim();
      final isValid = await authDataSource.validateResetToken(token);
      if (!isValid) {
        setState(() {
          _message = 'Token inválido o expirado.';
        });
        return;
      }
      await authDataSource.resetPassword(
        token,
        _passwordController.text.trim(),
      );
      setState(() {
        _message = 'Contraseña restablecida correctamente.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error al restablecer la contraseña. Intenta de nuevo.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'Token de recuperación',
                ),
                validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Token requerido',
                enabled: !_loading,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
                enabled: !_loading,
              ),
              const SizedBox(height: 24),
              if (_message != null) ...[
                Text(_message!, style: TextStyle(color: Colors.green)),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Restablecer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
      await authDataSource.forgotPassword(_emailController.text.trim());
      setState(() {
        _message =
            'Si el correo está registrado, se envió un enlace de recuperación.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error al enviar el correo. Intenta de nuevo.';
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
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Correo inválido',
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
                      : const Text('Enviar enlace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

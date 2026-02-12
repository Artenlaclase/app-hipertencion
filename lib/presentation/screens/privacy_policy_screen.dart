import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String policyUrl;
  const PrivacyPolicyScreen({super.key, required this.policyUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Consulta nuestra política de privacidad:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Abre el enlace en el navegador
                // Puedes usar url_launcher
              },
              child: const Text('Ver política de privacidad'),
            ),
            const SizedBox(height: 16),
            Text(
              policyUrl,
              style: const TextStyle(fontSize: 14, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

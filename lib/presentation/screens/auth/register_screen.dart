import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreler eşleşmiyor')),
      );
      return false;
    }

    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);

    if (height == null || weight == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli boy, kilo ve yaş değerleri girin')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre Tekrar',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Boy (cm)',
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Kilo (kg)',
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Yaş',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) => Column(
                  children: [
                    if (authProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          authProvider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                        if (_validateInputs()) {
                          await context.read<AuthProvider>().register(
                            email: _emailController.text,
                            password: _passwordController.text,
                            name: _nameController.text,
                            height: double.parse(_heightController.text),
                            weight: double.parse(_weightController.text),
                            age: int.parse(_ageController.text),
                          );
                        }
                      },
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Kayıt Ol'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().signInWithGoogle();
                },
                child: const Text('Google ile Kayıt Ol'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().signInWithFacebook();
                },
                child: const Text('Facebook ile Kayıt Ol'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Zaten hesabınız var mı? Giriş yapın'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

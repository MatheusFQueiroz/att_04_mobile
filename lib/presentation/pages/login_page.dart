import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_list_page.dart';

/// Tela de login.
///
/// Valida campos obrigatórios, chama POST /auth/login via [AuthViewModel],
/// e redireciona para [ProductListPage] em caso de sucesso.
class LoginPage extends StatefulWidget {
  final AuthViewModel authViewModel;
  final ProductViewModel productViewModel;

  const LoginPage({
    super.key,
    required this.authViewModel,
    required this.productViewModel,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authViewModel.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      widget.productViewModel.loadProducts();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListPage(
            viewModel: widget.productViewModel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 72, color: Colors.deepPurple),
              const SizedBox(height: 32),

              // Campo usuário
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o usuário' : null,
              ),
              const SizedBox(height: 16),

              // Campo senha
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a senha' : null,
              ),
              const SizedBox(height: 24),

              // Mensagem de erro
              ValueListenableBuilder(
                valueListenable: widget.authViewModel.state,
                builder: (context, state, _) {
                  if (state.error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              // Botão entrar
              ValueListenableBuilder(
                valueListenable: widget.authViewModel.state,
                builder: (context, state, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Entrar', style: TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              Text(
                'Credenciais de teste: emilys / emilyspass',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

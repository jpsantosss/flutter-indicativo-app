import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tcc/presentation/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/*
==================================== BLOCO 1 — CHAMADA DE API ====================================
A função `_login()` é responsável por realizar a comunicação com o backend Django, 
enviando as credenciais do usuário e tratando a resposta.

--- FLUXO DE EXECUÇÃO ---
1. Quando o usuário pressiona o botão "ENTRAR", a função `_login()` é chamada.
2. Define o estado `_isLoading = true` para exibir o indicador de carregamento e limpa mensagens anteriores.
3. Define o endpoint da API: `http://localhost:8000/api/login/`.
4. Faz uma requisição HTTP POST para esse endpoint usando o pacote `http`:
   - Cabeçalhos: `Content-Type: application/json`
   - Corpo: JSON contendo `username` e `password` digitados pelo usuário.
5. Se o servidor responder com **status 200**, o login foi bem-sucedido:
   - Usa `Navigator.pushReplacement` para redirecionar o usuário para a tela principal (`HomeScreen`).
6. Se o servidor retornar outro status (ex: 401), exibe a mensagem de erro:
   `"Usuário ou senha inválidos."`
7. Caso ocorra uma exceção (como falha de conexão), define o erro:
   `"Não foi possível conectar ao servidor."`
8. Ao final, independentemente do resultado, `_isLoading` volta a ser `false`
   para liberar o botão e encerrar o estado de carregamento.

--- RESUMO ---
A função `_login()` atua como um cliente HTTP que autentica o usuário no backend Django
utilizando o endpoint `/api/login/`. Se as credenciais estiverem corretas, 
o app prossegue para a tela principal do sistema.
===============================================================================================
*/
class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const String apiUrl = 'http://localhost:8000/api/login/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Usuário ou senha inválidos.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Não foi possível conectar ao servidor.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


/*----------------- FRONT-END -----------------*/
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    const Color accentColor = Color(0xFF2E95AC);
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: [
                          Image.asset('assets/images/logo.png', height: 200),
                          const SizedBox(height: 16),
                          const Text(
                            'IndicAtivo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      'USUÁRIO',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SENHA',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'ENTRAR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(color: accentColor, height: 5),
            Container(
              color: Colors.white,
              height: 100,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: const Text(
                    'João Pedro ®',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

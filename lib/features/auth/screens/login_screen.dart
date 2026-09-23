import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../events/screens/events_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthService authService;

  @override
  void initState() {
    super.initState();

    tokenStorage = TokenStorage();

    apiClient = ApiClient(
      tokenStorage: tokenStorage,
    );

    authService = AuthService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> login() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe o usuário e a senha.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.login(
        username: username,
        password: password,
      );

      final Map<String, dynamic> user =
          await authService.getCurrentUser();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EventsScreen(
            user: user,
          ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }

      String message = 'Não foi possível realizar o login.';

      if (error.response?.statusCode == 401) {
        message = 'Usuário ou senha inválidos.';
      } else if (error.type == DioExceptionType.connectionError) {
        message = 'Não foi possível conectar ao servidor.';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        message = 'O servidor demorou muito para responder.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocorreu um erro inesperado.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    size: 72,
                    color: Color(0xFF181717),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'GO FLASH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFF181717),
                    ),
                  ),

                  const Text(
                    '360',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 5,
                      color: Color(0xFF777777),
                    ),
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    'Bem-vindo!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181717),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Entre na sua conta para continuar.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF777777),
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: usernameController,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Usuário',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF181717),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    enabled: !isLoading,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        login();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF181717),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF181717),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF181717),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Go Flash 360',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
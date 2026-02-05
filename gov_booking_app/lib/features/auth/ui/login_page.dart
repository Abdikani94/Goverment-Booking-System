
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final phone = TextEditingController();
  final pass = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IconButton(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                    onPressed: () => context.go("/welcome"),
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: phone,
                    decoration: InputDecoration(
                      hintText: "Phone number",
                      filled: true,
                      fillColor: const Color(0xFFEEF2F7),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pass,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: const Color(0xFFEEF2F7),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => hidePassword = !hidePassword),
                        icon: Icon(
                          hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: auth.error == null
                        ? const SizedBox(height: 0)
                        : Padding(
                            key: const ValueKey("error"),
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              auth.error!,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2456D6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: auth.loading
                          ? null
                          : () async {
                              final role = await ref.read(authControllerProvider.notifier).login(
                                    phone: phone.text.trim(),
                                    password: pass.text,
                                  );
                              if (!context.mounted) return;
                              if (role == "ADMIN") context.go("/admin");
                              if (role == "CITIZEN") context.go("/citizen");
                            },
                      child: auth.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Login"),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () => context.go("/register"),
                    child: const Text(
                      "Create account",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
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

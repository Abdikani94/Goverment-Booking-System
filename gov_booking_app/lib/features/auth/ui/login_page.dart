
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
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = w > 520 ? 42.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: 0.96, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // ignore: prefer_const_constructors
                  Text(
                    "Welcome Back",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: titleSize, height: 1.0, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Login to continue your appointment journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF475569), fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x180F172A),
                          blurRadius: 24,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: phone,
                          decoration: const InputDecoration(
                            labelText: "Phone number",
                            filled: true,
                            fillColor: Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(14))),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: pass,
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(14))),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hidePassword = !hidePassword),
                              icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: auth.error == null
                              ? const SizedBox(height: 0)
                              : Padding(
                                  key: const ValueKey("error"),
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    auth.error!,
                                    style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
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
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text("Login"),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => context.go("/register"),
                            child: const Text("Create account"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

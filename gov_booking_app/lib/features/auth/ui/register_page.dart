import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final nid = TextEditingController();
  final pass = TextEditingController();
  final cpass = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final heroSize = w > 560 ? 48.0 : 38.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5FB),
        title: const Text("Citizen Registration"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 450),
              tween: Tween(begin: 0.97, end: 1),
              curve: Curves.easeOutCubic,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Column(
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.account_balance_rounded, size: 64, color: Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Create Account",
                    style: TextStyle(fontSize: heroSize, fontWeight: FontWeight.w900, height: 1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Register to start booking government office appointments.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF475569), fontSize: 16),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                      boxShadow: [
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
                          controller: name,
                          decoration: const InputDecoration(
                            labelText: "Full name",
                            filled: true,
                            hintText: "e.g. John Doe",
                            fillColor: Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: phone,
                          decoration: const InputDecoration(
                            labelText: "Phone",
                            filled: true,
                            hintText: "+1 (555) 000-0000",
                            fillColor: Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: nid,
                          decoration: const InputDecoration(
                            labelText: "National ID",
                            filled: true,
                            fillColor: Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: pass,
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            filled: true,
                            hintText: "At least 8 characters",
                            fillColor: const Color(0xFFF1F5F9),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hidePassword = !hidePassword),
                              icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: cpass,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirm password",
                            filled: true,
                            fillColor: Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Must include a letter, number and symbol.",
                            style: TextStyle(color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: auth.error == null
                              ? const SizedBox(height: 0)
                              : Text(
                                  auth.error!,
                                  key: const ValueKey("reg_error"),
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: auth.loading
                                ? null
                                : () async {
                                    if (pass.text != cpass.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Passwords do not match")),
                                      );
                                      return;
                                    }
                                    final role = await ref.read(authControllerProvider.notifier).register(
                                          fullName: name.text.trim(),
                                          phone: phone.text.trim(),
                                          nationalId: nid.text.trim(),
                                          password: pass.text,
                                        );
                                    if (!context.mounted) return;
                                    if (role == "CITIZEN") context.go("/citizen");
                                  },
                            child: auth.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text("Create account"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Color(0xFF475569))),
                      TextButton(onPressed: () => context.go("/welcome"), child: const Text("Log In")),
                    ],
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

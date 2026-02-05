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
  final pass = TextEditingController();
  final cpass = TextEditingController();
  bool agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        leading: IconButton(
          onPressed: () => context.go("/welcome"),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        ),
        title: const Text(
          "Create account",
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: name,
                  decoration: _fieldDecoration("Full name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phone,
                  decoration: _fieldDecoration("Phone number"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pass,
                  obscureText: true,
                  decoration: _fieldDecoration("Password"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cpass,
                  obscureText: true,
                  decoration: _fieldDecoration("Confirm password"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: agreeTerms,
                        onChanged: (v) => setState(() => agreeTerms = v ?? false),
                        activeColor: const Color(0xFF2456D6),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "I agree to terms",
                      style: TextStyle(fontSize: 16, color: Color(0xFF111827)),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: auth.error == null
                      ? const SizedBox(height: 0)
                      : Padding(
                          key: const ValueKey("reg_error"),
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            auth.error!,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
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
                            if (!agreeTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please agree to terms")),
                              );
                              return;
                            }
                            if (pass.text != cpass.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Passwords do not match")),
                              );
                              return;
                            }
                            final role = await ref.read(authControllerProvider.notifier).register(
                                  fullName: name.text.trim(),
                                  phone: phone.text.trim(),
                                  nationalId: phone.text.trim(),
                                  password: pass.text,
                                );
                            if (!context.mounted) return;
                            if (role == "CITIZEN") context.go("/citizen");
                          },
                    child: auth.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Create account",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 220),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    TextButton(
                      onPressed: () => context.go("/welcome"),
                      child: const Text(
                        "Log in",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      filled: true,
      fillColor: const Color(0xFFEEF0F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2456D6), width: 1.2),
      ),
    );
  }
}

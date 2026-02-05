import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../Shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      // Illustration Placeholder
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_mosaic_rounded,
                          size: 100,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          "Access for Citizens",
                          style: AppTypography.small(context)?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Welcome to Gov Booking",
                        style: AppTypography.h1(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Book an appointment in minutes.",
                        style: AppTypography.body(context)?.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: "Login",
                        onPressed: () => context.push("/login"),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: "Create account",
                        isSecondary: true,
                        onPressed: () => context.push("/register"),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "By continuing, you agree to our Terms of Service",
                        style: AppTypography.caption(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),

      ),
    );
  }
}


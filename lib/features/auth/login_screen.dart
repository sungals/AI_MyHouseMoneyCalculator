import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/primary_button.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';
import 'pin/pin_notifier.dart';
import 'pin/pin_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome(BuildContext ctx) {
    ctx.go('/');
  }

  Future<void> _continueAsGuest(BuildContext ctx) async {
    final box = Hive.box('app_settings');
    await box.put('login_skipped', true);
    if (!ctx.mounted) return;
    ctx.go('/');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      ref.read(authNotifierProvider.notifier).signUpWithEmail(email, password);
    } else {
      ref.read(authNotifierProvider.notifier).signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppAuthState>(
      authNotifierProvider,
      (previous, next) {
        if (next is AppAuthAuthenticated) {
          final pinState = ref.read(pinNotifierProvider);
          if (pinState is PinDisabled) {
            context.go('/pin-setup');
          } else {
            _navigateToHome(context);
          }
        }
      },
    );

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AppAuthLoading;
    final errorMessage =
        authState is AppAuthError ? authState.message : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // App logo/title area
              const Text(
                '집돈계산기',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '계산 결과를 저장하고 기기 간 동기화하세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Email TextField
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.cardRadius),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return '올바른 이메일 형식이 아닙니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Password TextField
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.cardRadius),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 최소 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Error message
              if (errorMessage != null)
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 24),
              // Primary Button
              PrimaryButton(
                label: _isSignUp ? '회원가입' : '로그인',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: 12),
              // Toggle sign-in/sign-up
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? '이미 계정이 있어요 → 로그인'
                        : '계정이 없어요 → 회원가입',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              const Divider(
                color: AppColors.divider,
                thickness: 1,
              ),
              const SizedBox(height: 16),
              // Guest mode button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('로그인 없이 계속하기'),
                  onPressed: () => _continueAsGuest(context),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

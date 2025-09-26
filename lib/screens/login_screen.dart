import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/di.dart';
import '../services/app_logger.dart';
import '../services/ui_notifier.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_navigation.dart';
import '../theme/app_colors.dart';
import 'settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final AppLogger _logger = di<AppLogger>();
  final UiNotifier _notifier = di<UiNotifier>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isEmail = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (user != null) {
          _logger.info('navigate: home after login');
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          setState(() {
            _errorMessage = 'Ошибка авторизации';
          });
          _notifier.showError(context, 'Не удалось войти');
        }
      }
    } catch (e) {
      _logger.error('login ui error', exception: e as Object?);
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _notifier.showError(context, _errorMessage ?? 'Ошибка авторизации');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: 'Task Manager',
        onSettings: _navigateToSettings,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ResponsiveContainer(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: ResponsiveUtils.getContentPadding(context),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: ResponsiveUtils.getResponsiveFontSize(context, 64),
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Task Manager',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Войдите в свой аккаунт',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                          _buildUsernameField(),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),
                          _buildPasswordField(),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 24),

                          if (_errorMessage != null) _buildErrorMessage(),
                          _buildLoginButton(),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),
                          _buildHelpText(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: _isEmail ? 'Email' : 'Имя пользователя',
        hintText: _isEmail
            ? 'Введите email'
            : 'Введите имя пользователя',
        prefixIcon: Icon(
          _isEmail
              ? Icons.email_outlined
              : Icons.person_outline,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isEmail
                ? Icons.person_outline
                : Icons.email_outlined,
          ),
          onPressed: () {
            setState(() {
              _isEmail = !_isEmail;
            });
          },
          tooltip: _isEmail
              ? 'Переключить на имя пользователя'
              : 'Переключить на email',
        ),
      ),
      keyboardType: _isEmail
          ? TextInputType.emailAddress
          : TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        // Автоматически определяем тип ввода
        if (value.contains('@')) {
          setState(() {
            _isEmail = true;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _isEmail
              ? 'Введите email'
              : 'Введите имя пользователя';
        }
        if (_isEmail) {
          if (!_authService.isValidEmail(value)) {
            return 'Введите корректный email';
          }
        } else {
          if (!_authService.isValidUsername(value)) {
            return 'Имя пользователя должно содержать только буквы, цифры и _';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Пароль',
        hintText: 'Введите пароль',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите пароль';
        }
        if (!_authService.isValidPassword(value)) {
          return 'Пароль должен содержать минимум 6 символов';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.danger,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.isMobile(context) ? 14 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.white,
                ),
              ),
            )
          : Text(
              'Войти',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildHelpText() {
    return Text(
      'Введите email или имя пользователя и пароль для входа',
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(
            color: AppColors.textMuted,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          ),
      textAlign: TextAlign.center,
    );
  }
}

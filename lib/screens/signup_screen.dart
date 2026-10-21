import 'package:flutter/material.dart';
import 'campus_shared.dart';
import 'login_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _showPw = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final err = await AuthService.register(
        _username.text.trim(), _email.text.trim(), _password.text);
    if (!mounted) return;

    if (err == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const LoginPage(justRegistered: true)));
    } else {
      setState(() {
        _loading = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Create account',
      subtitle: 'Join your campus community.',
      headline: 'Join your',
      highlight: 'campus',
      caption: 'Create an account to manage your organizations, events, and members.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Notice(kind: NoticeKind.error, message: _error!),
            CampusField(
              label: 'Username',
              controller: _username,
              hint: 'Enter username',
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Please choose a username.';
                if (s.length < 3) return 'Username must be at least 3 characters.';
                return null;
              },
            ),
            CampusField(
              label: 'Email',
              controller: _email,
              hint: 'Enter email',
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Please enter your email.';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            CampusField(
              label: 'Password',
              controller: _password,
              hint: 'At least 8 characters',
              obscure: !_showPw,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final s = v ?? '';
                if (s.isEmpty) return 'Please enter a password.';
                if (s.length < 8) return 'Password must be at least 8 characters.';
                return null;
              },
              suffix: IconButton(
                icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility,
                    size: 18, color: C.muted),
                onPressed: () => setState(() => _showPw = !_showPw),
              ),
            ),
            CampusField(
              label: 'Confirm Password',
              controller: _confirm,
              hint: 'Re-enter password',
              obscure: !_showPw,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) => (v ?? '') != _password.text
                  ? 'Passwords do not match.'
                  : null,
            ),
            const SizedBox(height: 24),
            GradientButton(
                label: 'Sign Up', loading: _loading, onPressed: _submit),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ',
                  style: TextStyle(fontSize: 13, color: C.muted)),
              InkWell(
                onTap: _loading
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text('Log in',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: C.lime)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
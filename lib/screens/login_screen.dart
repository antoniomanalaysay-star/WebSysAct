import 'package:flutter/material.dart';
import 'campus_shared.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginPage extends StatefulWidget {
  /// Shows the green "Account created!" banner (like ?registered in the PHP).
  final bool justRegistered;
  const LoginPage({super.key, this.justRegistered = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _showPw = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return; // block duplicate submits
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final ok = await AuthService.login(_email.text.trim(), _password.text);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      setState(() {
        _loading = false;
        _error = 'Invalid email or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Welcome',
      subtitle: 'Log in to continue.',
      headline: 'Stay connected on',
      highlight: 'campus',
      caption: 'Log in to manage your organizations, events, and members.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Notice(kind: NoticeKind.error, message: _error!)
            else if (widget.justRegistered)
              const Notice(
                  kind: NoticeKind.success,
                  message: 'Account created! Please log in.'),
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
              hint: 'Enter password',
              obscure: !_showPw,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) =>
                  (v ?? '').isEmpty ? 'Please enter your password.' : null,
              suffix: IconButton(
                icon: Icon(
                    _showPw ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: C.muted),
                onPressed: () => setState(() => _showPw = !_showPw),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password reset is not set up yet.'))),
                style: TextButton.styleFrom(
                    foregroundColor: C.gold,
                    padding: const EdgeInsets.symmetric(horizontal: 0)),
                child: const Text('Forgot Password?',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            GradientButton(
                label: 'Login', loading: _loading, onPressed: _submit),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? ",
                  style: TextStyle(fontSize: 13, color: C.muted)),
              InkWell(
                onTap: _loading
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SignupPage())),
                child: const Text('Sign up',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: C.lime)),
              ),
            ]),
            const SizedBox(height: 14),
            const Center(
              child: Text('Demo account: demo@campus.edu / demo1234',
                  style: TextStyle(fontSize: 11, color: C.muted)),
            ),
          ],
        ),
      ),
    );
  }
}
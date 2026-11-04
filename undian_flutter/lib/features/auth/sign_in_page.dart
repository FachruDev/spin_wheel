import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../core/server/server_providers.dart';
import '../../core/ui/async_view.dart';
import '../offline/offline_providers.dart';

/// Masuk, daftar akun, dan lupa password dengan email. Tampilan sendiri berbahasa Indonesia;
/// alurnya memakai [EmailAuthController] dari modul auth Serverpod.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  late final _auth = EmailAuthController(client: ref.read(clientProvider));
  var _showPassword = false;

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: ListenableBuilder(
                  listenable: _auth,
                  builder: (context, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.card_giftcard_rounded, size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(_title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text(_subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      ..._fields(),
                      if (_errorText case final error?) ...[
                        const SizedBox(height: 12),
                        Text(error, style: TextStyle(color: theme.colorScheme.error)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _auth.isLoading ? null : _submit,
                          child: _auth.isLoading
                              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(_submitLabel),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._links(),
                      if (_screen == EmailFlowScreen.login && ref.watch(offlineFilesProvider) != null) ...[
                        const Divider(height: 32),
                        OutlinedButton.icon(
                          key: const ValueKey('offline-mode'),
                          onPressed: _auth.isLoading ? null : _enterOffline,
                          icon: const Icon(Icons.cloud_off_rounded),
                          label: const Text('Mode offline (tanpa server)'),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Data disimpan di laptop ini. Pakai saat server bermasalah, '
                          'lalu impor paket acara dari laptop lain atau dari salinan otomatis.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
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

  EmailFlowScreen get _screen => _auth.currentScreen;

  String get _title => switch (_screen) {
    EmailFlowScreen.login => 'Masuk',
    EmailFlowScreen.startRegistration ||
    EmailFlowScreen.verifyRegistration ||
    EmailFlowScreen.completeRegistration => 'Daftar akun',
    _ => 'Atur ulang password',
  };

  String get _subtitle => switch (_screen) {
    EmailFlowScreen.login => 'Aplikasi undian doorprize & grand prize',
    EmailFlowScreen.startRegistration => 'Kami akan mengirim kode verifikasi ke email Anda.',
    EmailFlowScreen.verifyRegistration ||
    EmailFlowScreen.verifyPasswordReset => 'Masukkan kode yang dikirim ke ${_auth.emailController.text.trim()}.',
    EmailFlowScreen.completeRegistration => 'Buat password untuk akun Anda.',
    EmailFlowScreen.requestPasswordReset => 'Kami akan mengirim kode untuk membuat password baru.',
    EmailFlowScreen.completePasswordReset => 'Buat password baru.',
  };

  String get _submitLabel => switch (_screen) {
    EmailFlowScreen.login => 'Masuk',
    EmailFlowScreen.startRegistration || EmailFlowScreen.requestPasswordReset => 'Kirim kode',
    EmailFlowScreen.verifyRegistration || EmailFlowScreen.verifyPasswordReset => 'Verifikasi',
    EmailFlowScreen.completeRegistration => 'Buat akun',
    EmailFlowScreen.completePasswordReset => 'Simpan password',
  };

  List<Widget> _fields() {
    // Key berbeda per isian: tanpa ini Flutter memakai ulang kolom email untuk kolom kode,
    // sehingga sambungan input keyboard bisa tertinggal di controller lama.
    final email = TextField(
      key: const ValueKey('email'),
      controller: _auth.emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
      onSubmitted: (_) => _submit(),
    );
    final password = TextField(
      key: const ValueKey('password'),
      controller: _auth.passwordController,
      obscureText: !_showPassword,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password',
        helperText: _screen == EmailFlowScreen.login ? null : 'Minimal 8 karakter, tanpa spasi di awal/akhir.',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _showPassword ? 'Sembunyikan' : 'Tampilkan',
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        ),
      ),
      onSubmitted: (_) => _submit(),
    );
    final code = TextField(
      key: const ValueKey('code'),
      controller: _auth.verificationCodeController,
      decoration: const InputDecoration(labelText: 'Kode verifikasi', prefixIcon: Icon(Icons.pin_outlined)),
      onSubmitted: (_) => _submit(),
    );
    return switch (_screen) {
      EmailFlowScreen.login => [email, const SizedBox(height: 12), password],
      EmailFlowScreen.startRegistration || EmailFlowScreen.requestPasswordReset => [email],
      EmailFlowScreen.verifyRegistration || EmailFlowScreen.verifyPasswordReset => [code],
      EmailFlowScreen.completeRegistration || EmailFlowScreen.completePasswordReset => [password],
    };
  }

  List<Widget> _links() {
    final widgets = <Widget>[];
    void link(String label, VoidCallback onPressed) =>
        widgets.add(TextButton(onPressed: _auth.isLoading ? null : onPressed, child: Text(label)));
    switch (_screen) {
      case EmailFlowScreen.login:
        link('Belum punya akun? Daftar', () => _auth.navigateTo(EmailFlowScreen.startRegistration));
        link('Lupa password', () => _auth.navigateTo(EmailFlowScreen.requestPasswordReset));
      case EmailFlowScreen.verifyRegistration || EmailFlowScreen.verifyPasswordReset:
        link('Kirim ulang kode', _auth.resendVerificationCode);
        link('Kembali ke halaman masuk', () => _auth.navigateTo(EmailFlowScreen.login));
      default:
        link('Kembali ke halaman masuk', () => _auth.navigateTo(EmailFlowScreen.login));
    }
    return widgets;
  }

  Future<void> _enterOffline() async {
    try {
      await enterOfflineMode(ref);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _submit() async {
    if (_auth.isLoading) return;
    await switch (_screen) {
      EmailFlowScreen.login => _auth.login(),
      EmailFlowScreen.startRegistration => _auth.startRegistration(),
      EmailFlowScreen.verifyRegistration => _auth.verifyRegistrationCode(),
      EmailFlowScreen.completeRegistration => _auth.finishRegistration(),
      EmailFlowScreen.requestPasswordReset => _auth.startPasswordReset(),
      EmailFlowScreen.verifyPasswordReset => _auth.verifyPasswordResetCode(),
      EmailFlowScreen.completePasswordReset => _auth.finishPasswordReset(),
    };
    // Setelah login berhasil, router mengalihkan ke beranda lewat perubahan status sesi.
  }

  /// Pesan error modul auth (berbahasa Inggris) diterjemahkan untuk kasus yang umum.
  String? get _errorText {
    final error = _auth.error;
    if (error == null) return null;
    final text = error.toString();
    final lower = text.toLowerCase();
    if (lower.contains('invalidcredentials') || lower.contains('invalid credentials')) {
      return 'Email atau password salah.';
    }
    if (lower.contains('toomanyattempts') || lower.contains('too many')) {
      return 'Terlalu banyak percobaan. Tunggu beberapa menit lalu coba lagi.';
    }
    if (lower.contains('invalidverificationcode') || lower.contains('invalid') && lower.contains('code')) {
      return 'Kode verifikasi salah atau sudah kedaluwarsa.';
    }
    if (lower.contains('policyviolation') || lower.contains('password')) {
      return 'Password belum memenuhi syarat: minimal 8 karakter, tanpa spasi di awal/akhir.';
    }
    if (lower.contains('email')) return 'Alamat email tidak valid.';
    return text;
  }
}

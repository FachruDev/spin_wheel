import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';

enum VerificationPurpose { registration, passwordReset }

/// Pengaturan SMTP dari passwords.yaml atau environment `SERVERPOD_PASSWORD_smtp*`.
class SmtpSettings {
  const SmtpSettings({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.fromAddress,
    required this.fromName,
  });

  final String host;
  final int port;
  final String username;
  final String password;
  final String fromAddress;
  final String fromName;

  /// Null bila smtpHost belum diisi. Port bawaan 587 (STARTTLS); 465 memakai SSL langsung.
  static SmtpSettings? fromPasswords(String? Function(String key) password) {
    final host = password('smtpHost')?.trim() ?? '';
    if (host.isEmpty) return null;
    final username = password('smtpUsername')?.trim() ?? '';
    return SmtpSettings(
      host: host,
      port: int.tryParse(password('smtpPort') ?? '') ?? 587,
      username: username,
      password: password('smtpPassword') ?? '',
      fromAddress: password('smtpFrom')?.trim().isNotEmpty == true ? password('smtpFrom')!.trim() : username,
      fromName: password('smtpFromName')?.trim().isNotEmpty == true ? password('smtpFromName')!.trim() : 'Undian',
    );
  }
}

/// Isi email kode verifikasi (teks biasa) dalam bahasa Indonesia.
({String subject, String body}) verificationEmail(VerificationPurpose purpose, String code) {
  final (subject, intro, ignore) = switch (purpose) {
    VerificationPurpose.registration => (
      'Kode verifikasi pendaftaran Undian',
      'Kode verifikasi untuk mendaftar di aplikasi Undian:',
      'Jika Anda tidak merasa mendaftar, abaikan email ini.',
    ),
    VerificationPurpose.passwordReset => (
      'Kode untuk membuat password baru di Undian',
      'Kode untuk membuat password baru akun Undian Anda:',
      'Jika Anda tidak meminta pergantian password, abaikan email ini; password lama tetap berlaku.',
    ),
  };
  return (
    subject: subject,
    body:
        'Halo,\n\n'
        '$intro\n\n'
        '    $code\n\n'
        'Masukkan kode ini di aplikasi. Kode hanya berlaku sebentar dan hanya bisa dipakai sekali.\n'
        '$ignore\n',
  );
}

/// Mengirim kode verifikasi lewat SMTP.
///
/// Tanpa SMTP: di mode pengembangan/tes kode ditulis ke log (dipakai skrip demo dan uji
/// ujung-ke-ujung); di mode lain dilempar error, karena kode tidak boleh masuk log produksi.
class VerificationMailer {
  VerificationMailer(this.settings);

  final SmtpSettings? settings;

  Future<void> send(
    Session session, {
    required String email,
    required String code,
    required VerificationPurpose purpose,
  }) async {
    final smtp = settings;
    if (smtp == null) {
      final runMode = session.serverpod.runMode;
      if (runMode == ServerpodRunMode.development || runMode == ServerpodRunMode.test) {
        final label = purpose == VerificationPurpose.registration ? 'Registration code' : 'Password reset code';
        session.log('[EmailIdp] $label ($email): $code');
        return;
      }
      session.log('SMTP belum diatur (smtpHost kosong); kode verifikasi tidak bisa dikirim.', level: LogLevel.error);
      throw StateError('SMTP belum diatur');
    }

    final content = verificationEmail(purpose, code);
    final message = mailer.Message()
      ..from = mailer.Address(smtp.fromAddress, smtp.fromName)
      ..recipients.add(email)
      ..subject = content.subject
      ..text = content.body;
    final server = SmtpServer(
      smtp.host,
      port: smtp.port,
      ssl: smtp.port == 465,
      username: smtp.username.isEmpty ? null : smtp.username,
      password: smtp.password.isEmpty ? null : smtp.password,
    );
    try {
      await mailer.send(message, server, timeout: const Duration(seconds: 30));
      session.log('Email ${purpose.name} terkirim ke $email');
    } on mailer.MailerException catch (e) {
      session.log('Gagal mengirim email ke $email: ${e.message}', level: LogLevel.error);
      rethrow;
    }
  }
}

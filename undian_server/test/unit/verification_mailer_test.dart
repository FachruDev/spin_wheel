import 'package:test/test.dart';
import 'package:undian_server/src/email/verification_mailer.dart';

void main() {
  group('SmtpSettings.fromPasswords', () {
    test('tanpa smtpHost berarti SMTP belum diatur', () {
      expect(SmtpSettings.fromPasswords((_) => null), isNull);
      expect(SmtpSettings.fromPasswords((key) => key == 'smtpHost' ? '  ' : null), isNull);
    });

    test('port bawaan 587; pengirim bawaan = username dan nama "Undian"', () {
      final values = {'smtpHost': 'smtp.contoh.id', 'smtpUsername': 'no-reply@contoh.id', 'smtpPassword': 'x'};
      final settings = SmtpSettings.fromPasswords((key) => values[key])!;
      expect(settings.host, 'smtp.contoh.id');
      expect(settings.port, 587);
      expect(settings.fromAddress, 'no-reply@contoh.id');
      expect(settings.fromName, 'Undian');
    });

    test('port, alamat, dan nama pengirim bisa diatur', () {
      final values = {
        'smtpHost': 'smtp.contoh.id',
        'smtpPort': '465',
        'smtpUsername': 'user',
        'smtpFrom': 'undian@contoh.id',
        'smtpFromName': 'Panitia Undian',
      };
      final settings = SmtpSettings.fromPasswords((key) => values[key])!;
      expect((settings.port, settings.fromAddress, settings.fromName), (465, 'undian@contoh.id', 'Panitia Undian'));
    });
  });

  test('isi email memuat kode dan berbeda untuk daftar dan lupa password', () {
    final registration = verificationEmail(VerificationPurpose.registration, '12345678');
    final reset = verificationEmail(VerificationPurpose.passwordReset, '87654321');
    expect(registration.body, contains('12345678'));
    expect(registration.subject, contains('pendaftaran'));
    expect(reset.body, contains('87654321'));
    expect(reset.subject, contains('password baru'));
  });
}

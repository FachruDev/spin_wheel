; Installer Windows untuk aplikasi Undian (Inno Setup 6.2 atau lebih baru).
;
; Jangan dikompilasi langsung. Jalankan dari folder undian_flutter:
;   powershell -ExecutionPolicy Bypass -File tool\build_windows_installer.ps1 -ServerUrl https://api.contoh.co.id/
; Skrip itu membangun aplikasi dengan alamat server yang benar, lalu mengisi definisi di bawah.

#ifndef AppVersion
  #error AppVersion belum diisi. Jalankan lewat tool\build_windows_installer.ps1.
#endif
#ifndef SourceDir
  #error SourceDir belum diisi. Jalankan lewat tool\build_windows_installer.ps1.
#endif
#ifndef WizardDir
  #error WizardDir belum diisi. Jalankan lewat tool\build_windows_installer.ps1.
#endif
#ifndef OutputDir
  #define OutputDir "..\..\build\installer"
#endif

#define AppName "Undian"
#define AppExe "undian.exe"

[Setup]
; AppId mengenali aplikasi saat pembaruan dan uninstall. Jangan pernah diganti.
AppId={{5B4B9FAF-5AC3-4591-81F2-7DA6717D6721}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppName}
VersionInfoVersion={#AppVersion}
VersionInfoProductName={#AppName}
VersionInfoDescription=Installer {#AppName}

; Tanpa hak admin: dipasang untuk pengguna ini di %LOCALAPPDATA%\Programs\Undian.
; Pengguna dengan hak admin bisa memilih "untuk semua pengguna" (Program Files).
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
UsePreviousAppDir=yes

ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=10.0

OutputDir={#OutputDir}
OutputBaseFilename=Undian-Setup-{#AppVersion}
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
WizardStyle=modern
WizardImageFile={#WizardDir}\wizard-100.bmp,{#WizardDir}\wizard-150.bmp,{#WizardDir}\wizard-200.bmp
WizardSmallImageFile={#WizardDir}\wizard-small-100.bmp,{#WizardDir}\wizard-small-150.bmp,{#WizardDir}\wizard-small-200.bmp
Compression=lzma2/max
SolidCompression=yes

; Aplikasi yang sedang terbuka ditutup dulu saat memperbarui.
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[InstallDelete]
; Aset Flutter versi lama dihapus supaya tidak tercampur dengan versi baru.
Type: filesandordirs; Name: "{app}\data"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

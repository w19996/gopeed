#define MyAppName "Gopeed"
#define MyAppVersion "__APP_VERSION__"
#define MyAppPublisher "monkeyWie"
#define MyAppURL "https://gopeed.com"
#define MyAppExeName "gopeed.exe"
#define MyAppSourceDir "__SOURCE_DIR__"
#define MyAppOutputDir "__OUTPUT_DIR__"
#define MyAppOutputBaseFilename "__OUTPUT_BASENAME__"
#define MyAppLicenseFile "__LICENSE_FILE__"
#define MyAppIconFile "__ICON_FILE__"

[Setup]
AppId={{5960F34D-1E42-402C-8C85-DE2FF24CBAE4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\gopeed
DisableProgramGroupPage=yes
LicenseFile={#MyAppLicenseFile}
PrivilegesRequired=lowest
OutputDir={#MyAppOutputDir}
OutputBaseFilename={#MyAppOutputBaseFilename}
SetupIconFile={#MyAppIconFile}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ShowLanguageDialog=no

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyAppSourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

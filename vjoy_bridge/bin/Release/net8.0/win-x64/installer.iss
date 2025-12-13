[Setup]
AppName=Steer Beamng
AppVersion=1.0
DefaultDirName={pf}\Steer Beamng
DefaultGroupName=Steer Beamng
OutputDir=.
OutputBaseFilename=SteerBeamNGInstaller
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin

[Files]
; vJoy driver installer
Source: "vJoySetup.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

; App files
Source: "publish\Steer Beamng.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "publish\vJoyInterface.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "allow_firewall.bat"; DestDir: "{app}"; Flags: ignoreversion

[Run]
; Install vJoy FIRST
Filename: "{tmp}\vJoySetup.exe"; Flags: waituntilterminated runascurrentuser

; Firewall rule
Filename: "{app}\allow_firewall.bat"; Flags: runhidden waituntilterminated

; Launch app
Filename: "{app}\Steer Beamng.exe"; Flags: nowait postinstall skipifsilent

[Icons]
Name: "{group}\Steer Beamng"; Filename: "{app}\Steer Beamng.exe"
Name: "{commondesktop}\Steer Beamng"; Filename: "{app}\Steer Beamng.exe"

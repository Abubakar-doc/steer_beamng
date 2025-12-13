@echo off

:: Require admin (silent exit if not)
net session >nul 2>&1 || exit /b

set PORT=5000

:: Remove old rule if exists
netsh advfirewall firewall delete rule name="Steer BeamNG UDP" >nul 2>&1

:: Add UDP rule (broadcast + discovery safe)
netsh advfirewall firewall add rule ^
 name="Steer BeamNG UDP" ^
 dir=in action=allow ^
 protocol=UDP ^
 localport=%PORT% ^
 profile=private,public ^
 enable=yes >nul

exit /b

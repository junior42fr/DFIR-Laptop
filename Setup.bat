powershell -Command "& {start-process powershell -verb RunAs -ArgumentList '-Command &{Set-ExecutionPolicy Unrestricted}'}"
timeout /t 1
powershell -Command "& {.\installer.ps1}"
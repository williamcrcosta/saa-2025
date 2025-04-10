# This script installs the IIS web server on a Windows machine.
# It uses the Add-WindowsFeature cmdlet to install the Web-Server feature along with management tools.

# Desativa Firewall Windows
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

# Install IIS
Add-WindowsFeature -Name Web-Server -IncludeManagementTools

# Faz download do Dotnet Hosting copiando para a raiz do disco C.
Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.15/dotnet-hosting-8.0.15-win.exe" -OutFile C:\dotnet-hosting-8.0.15-win.exe;

# Instala o Dotnet Hosting sem wizard
C:\dotnet-hosting-8.0.15-win.exe /quiet

# Valida a instalação do Hosting
dotnet --list-runtimes

Realiza o restart da maquina pós instalação dos componentes.
Restart-Computer -Force
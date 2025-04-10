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

#Faz download do pacote das publicações e Banco
Invoke-WebRequest -Uri "https://stodiskdesafio.blob.core.windows.net/saa2025/Aplicacao.zip" -OutFile C:\Aplicacao.zip;

# Extrai os arquivos e adiciona no diretório wwwroot
Expand-Archive C:\Aplicacao.zip -DestinationPath C:\

# Copy-Item -Path C:\dash -Destination C:\inetpub\wwwroot\
Copy-Item -Path "C:\dash\" -Destination "C:\inetpub\wwwroot\" -Recurse -Force

Copy-Item -Path "C:\Sistema\" -Destination "C:\inetpub\wwwroot\" -Recurse -Force

#Copy-Item -Path C:\Sistema -Destination C:\inetpub\wwwroot\

##Expand-Archive C:\Users\Administrator\Downloads\Sistema.zip -DestinationPath C:\inetpub\wwwroot\

# Remove arquivo do Banco de Dados
##Remove-Item -Path C:\inetpub\wwwroot\Sistema\*.bacpac -Recurse

# Stop do Site Default
Stop-WebSite -Name "Default Web Site"

# Remove-Website -Name "Default Web Site"

#Remove-Item -Path IIS:\AppPools\DefaultAppPool

# New-WebAppPool -Name Sistema -Force

# Criar Application Pool Sistema
New-Item –Path IIS:\AppPools\Sistema

# Criar novo Web-Site Sistema
New-Website -Name "Sistema" -Port 80 -PhysicalPath "C:\inetpub\wwwroot\Sistema" -ApplicationPool "Sistema"

# Criar Application Pool Sistema
New-Item –Path IIS:\AppPools\Dash

#Cra novo Web-Site
New-Website -Name "Dash" -Port 8080 -PhysicalPath "C:\inetpub\wwwroot\Dash" -ApplicationPool "Dash"

# Realiza o restart da maquina pós instalação dos componentes.
Restart-Computer -Force
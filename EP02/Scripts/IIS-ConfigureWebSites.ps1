#Faz download do pacote das publicações e Banco
Invoke-WebRequest -Uri "https://stodiskdesafio.blob.core.windows.net/saa2025/Aplicacao.zip" -OutFile C:\Aplicacao.zip;

# Extrai os arquivos e adiciona no diretório wwwroot
Expand-Archive C:\Aplicacao.zip -DestinationPath C:\

# Copy-Item -Path C:\dash -Destination C:\inetpub\wwwroot\
Copy-Item -Path "C:\dash\" -Destination "C:\inetpub\wwwroot\dash" -Recurse -Force

Copy-Item -Path "C:\Sistema\" -Destination "C:\inetpub\wwwroot\Sistema" -Recurse -Force


Stop-WebSite -Name "Default Web Site"
Remove-Website -Name "Default Web Site"
Remove-Item -Path IIS:\AppPools\DefaultAppPool

New-Item –Path IIS:\AppPools\Sistema -Force
New-Website -Name "Sistema" -Port 80 -PhysicalPath "C:\inetpub\wwwroot\Sistema" -ApplicationPool "Sistema"

New-Item –Path IIS:\AppPools\Dash
New-Website -Name "Dash" -Port 8080 -PhysicalPath "C:\inetpub\wwwroot\Dash" -ApplicationPool "Dash"

Realiza o restart da maquina pós instalação dos componentes.
Restart-Computer -Force